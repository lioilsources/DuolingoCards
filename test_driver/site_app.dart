import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/main.dart';
import 'package:duolingo_cards/services/deck_download_service.dart';
import 'package:duolingo_cards/services/entitlement_service.dart';
import 'package:duolingo_cards/services/language_deck_service.dart';
import 'package:duolingo_cards/theme/app_theme.dart';
import 'package:duolingo_cards/utils/language_names.dart';

/// App side of `make site-screenshots`: the real app, not a test binding (so
/// fonts, emoji and the status bar are what a phone shows), with the driver
/// extension on and a learner's home screen already set up.
///
/// Home shows three free decks, each in a different language pair and look.
/// The learner's own language is the device's, so a Czech run teaches from
/// Czech and an English one (the App Store listing) from English.
const _home = [
  ('numbers-1-10', 'es', 'ink'),
  ('geo-flags', 'de', 'flag'),
  ('animals-pets', 'en', 'photo'),
];

/// The card the study shots show. The study screen draws at random, and the
/// draw once landed on the deck's darkest picture.
const _studyDeck = 'animals-pets';
const _studyCard = 'pet.hamster';
const _studyPrefs = 'card_priorities_$_studyDeck';

const _pointer = 4242;
Offset _dragAt = Offset.zero;

Future<String> _handle(String? message) async {
  final view = PlatformDispatcher.instance.views.first;
  switch (message) {
    // Everything the host needs to find widgets by their visible text.
    case 'strings':
      final locale = PlatformDispatcher.instance.locale;
      // The full device locale, so zh-Hant and pt-PT pick their own ARB.
      final l10n = lookupAppLocalizations(locale);
      final decks = LanguageDeckService.instance;
      Future<String> title(String slug) async =>
          (await decks.load(slug)).title(locale.languageCode);
      return jsonEncode({
        'store': l10n.homeStoreTooltip,
        'watercolor': l10n.styleWatercolor,
        'pets': await title('animals-pets'),
        'flags': await title('geo-flags'),
        'weather': await title('weather'),
        'l2': langDisplayName('ar', l10n),
        'l2pick': langDisplayName('ja', l10n),
      });
    // Weight every other card of the study deck to zero, so the draw can only
    // return [_studyCard]. Done after the home shot — the tile's progress bar
    // reads the same numbers — and undone by 'unpin'.
    case 'pin':
      final deck = await LanguageDeckService.instance.load(_studyDeck);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _studyPrefs,
          jsonEncode({
            for (final c in deck.cards)
              c.priorityId: {'priority': c.priorityId == _studyCard ? 10 : 0},
          }));
      return 'ok';
    case 'unpin':
      await (await SharedPreferences.getInstance()).remove(_studyPrefs);
      return 'ok';
    // Hold a card mid-swipe to the right, far enough for the heart to show.
    case 'drag':
      final size = view.physicalSize / view.devicePixelRatio;
      _dragAt = size.center(Offset.zero);
      GestureBinding.instance.handlePointerEvent(
          PointerDownEvent(pointer: _pointer, position: _dragAt));
      for (var i = 0; i < 14; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        _dragAt += const Offset(8, 0);
        GestureBinding.instance.handlePointerEvent(PointerMoveEvent(
            pointer: _pointer, position: _dragAt, delta: const Offset(8, 0)));
      }
      return 'ok';
    case 'release':
      GestureBinding.instance.handlePointerEvent(
          PointerUpEvent(pointer: _pointer, position: _dragAt));
      return 'ok';
  }
  return 'unknown';
}

const _emoji = 'Lexify Screenshot Emoji';

/// The iOS 26.2 / 26.3 simulator runtimes cannot load their own colour-emoji
/// font, so every flag is drawn as a boxed question mark there (Apple forums
/// thread 817957; phones and the 26.4 simulator are fine). A simulator process
/// can read the Mac's files, so load the Mac's copy and put it at the end of
/// every text style's fallback list. Returns null where there is nothing to
/// work around.
Future<ThemeData?> _themeWithLentEmoji() async {
  final font = File('/System/Library/Fonts/Apple Color Emoji.ttc');
  if (!Platform.isIOS || !font.existsSync()) return null;
  final bytes = (await font.readAsBytes()).buffer.asByteData();
  await (FontLoader(_emoji)..addFont(Future.value(bytes))).load();

  TextStyle? lend(TextStyle? s) => s?.copyWith(
      fontFamilyFallback: [...?s.fontFamilyFallback, _emoji]);
  TextTheme all(TextTheme t) => t.copyWith(
        displayLarge: lend(t.displayLarge),
        displayMedium: lend(t.displayMedium),
        displaySmall: lend(t.displaySmall),
        headlineLarge: lend(t.headlineLarge),
        headlineMedium: lend(t.headlineMedium),
        headlineSmall: lend(t.headlineSmall),
        titleLarge: lend(t.titleLarge),
        titleMedium: lend(t.titleMedium),
        titleSmall: lend(t.titleSmall),
        bodyLarge: lend(t.bodyLarge),
        bodyMedium: lend(t.bodyMedium),
        bodySmall: lend(t.bodySmall),
        labelLarge: lend(t.labelLarge),
        labelMedium: lend(t.labelMedium),
        labelSmall: lend(t.labelSmall),
      );
  final base = AppTheme.light();
  return base.copyWith(
    textTheme: all(base.textTheme),
    primaryTextTheme: all(base.primaryTextTheme),
  );
}

Future<void> main() async {
  enableFlutterDriverExtension(handler: _handle);
  // The driver refuses commands until a root widget exists, and the setup
  // below downloads three decks first.
  runApp(const SizedBox.shrink());
  final theme = await _themeWithLentEmoji();
  final ent = EntitlementService();
  await ent.initialize();
  final l1 = PlatformDispatcher.instance.locale.languageCode;
  for (final (slug, l2, style) in _home) {
    await DeckDownloadService.instance.downloadDeck(slug, style);
    // Never a deck that teaches a language from itself.
    await ent.activate(slug, l1, l2 == l1 ? 'fr' : l2, style, tier: 0);
  }
  runApp(LexifyApp(theme: theme));
}
