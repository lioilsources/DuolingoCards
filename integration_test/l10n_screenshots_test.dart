import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/main.dart';
import 'package:duolingo_cards/services/deck_download_service.dart';
import 'package:duolingo_cards/services/entitlement_service.dart';

/// On-device screenshots of every screen that carries UI chrome, once per UI
/// language, so a build can be eyeballed for mixed languages before it goes to
/// App Review (2.2.2 was rejected under guideline 4 for exactly that).
///
///     make screenshots            # booted iOS simulator → build/screenshots/
///
/// The device locale is overridden per run through the test binding, so one
/// simulator produces every language. Nothing here is asserted beyond the
/// screens rendering — the pictures are the deliverable.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Real plugins and network calls finish in real time, not in pumped frames,
  /// so wait wall-clock between frames instead of pumpAndSettle (which would
  /// spin forever on a loading indicator).
  Future<void> settle(WidgetTester tester,
      {Duration total = const Duration(seconds: 3)}) async {
    const step = Duration(milliseconds: 250);
    for (var t = Duration.zero; t < total; t += step) {
      await tester.pump();
      await Future<void>.delayed(step);
    }
  }

  setUpAll(() async {
    // A home tile needs a deck whose images are on the device; the free pets
    // deck comes from the CDN like it would for a user.
    final ent = EntitlementService();
    await ent.initialize();
    await DeckDownloadService.instance.downloadDeck('animals-pets', 'photo');
    await ent.activate('animals-pets', 'en', 'es-419', 'photo', tier: 0);
  });

  for (final locale in LexifyApp.supportedLocales) {
    final tag = locale.languageCode;
    testWidgets('$tag: home, store, detail, confirm dialog', (tester) async {
      final dispatcher = tester.binding.platformDispatcher;
      dispatcher.localeTestValue = locale;
      dispatcher.localesTestValue = [locale];
      addTearDown(() {
        dispatcher.clearLocaleTestValue();
        dispatcher.clearLocalesTestValue();
      });
      final l10n = lookupAppLocalizations(locale);

      await tester.pumpWidget(LexifyApp(key: ValueKey(tag)));
      await settle(tester, total: const Duration(seconds: 5));
      await binding.takeScreenshot('${tag}_1_home');

      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await settle(tester);
      await binding.takeScreenshot('${tag}_2_store');

      await tester.tap(find.byType(ListTile).first);
      await settle(tester);
      await binding.takeScreenshot('${tag}_3_detail');

      // The one FilledButton on the page is the action button; whatever it
      // says for this deck (Add / Buy for …), tapping it opens the
      // confirmation dialog — unless the combination is already on the home
      // screen, in which case it would start a download, so skip that.
      final action = find.byWidgetPredicate((w) => w is FilledButton);
      final alreadyActivated = find.text(l10n.study).evaluate().isNotEmpty ||
          find.text(l10n.download).evaluate().isNotEmpty;
      if (action.evaluate().isNotEmpty && !alreadyActivated) {
        await tester.tap(action.first);
        await settle(tester, total: const Duration(seconds: 2));
        await binding.takeScreenshot('${tag}_4_confirm');
      }
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}
