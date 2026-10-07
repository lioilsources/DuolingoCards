import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

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
const _home = [
  ('numbers-1-10', 'cs', 'es', 'ink'),
  ('geo-flags', 'cs', 'de', 'flag'),
  ('animals-pets', 'cs', 'en', 'photo'),
];

const _pointer = 4242;
Offset _dragAt = Offset.zero;

Future<String> _handle(String? message) async {
  final view = PlatformDispatcher.instance.views.first;
  switch (message) {
    // Everything the host needs to find widgets by their visible text.
    case 'strings':
      final locale = PlatformDispatcher.instance.locale;
      final l10n = lookupAppLocalizations(Locale(locale.languageCode));
      final decks = LanguageDeckService.instance;
      Future<String> title(String slug) async =>
          (await decks.load(slug)).title(locale.languageCode);
      return jsonEncode({
        'store': l10n.homeStoreTooltip,
        'watercolor': l10n.styleWatercolor,
        'pets': await title('animals-pets'),
        'weather': await title('weather'),
        'l2': langDisplayName('ar', l10n),
        'l2pick': langDisplayName('ja', l10n),
      });
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
  for (final (slug, l1, l2, style) in _home) {
    await DeckDownloadService.instance.downloadDeck(slug, style);
    await ent.activate(slug, l1, l2, style, tier: 0);
  }
  runApp(LexifyApp(theme: theme));
}
