// The checks every app copies from ol1n_telemetry (dictionary ↔ doc, no free
// text, version ↔ pubspec, literal event names, no key → no network, off →
// nothing), plus Lexify's own rule: nothing is measured on Android.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:ol1n_telemetry/testing.dart';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/main.dart';
import 'package:duolingo_cards/screens/settings_screen.dart';
import 'package:duolingo_cards/telemetry/telemetry_dictionary.dart';
import 'package:duolingo_cards/telemetry/telemetry_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ol1n_telemetry kit', () {
    test('docs/telemetry.md lists exactly the dictionary', () {
      expect(
          telemetryDocProblems(
              lexifyDictionary, File('docs/telemetry.md').readAsStringSync()),
          isEmpty);
    });

    test('no property is free text', () {
      expect(telemetryDictionaryProblems(lexifyDictionary), isEmpty);
    });

    test('app version matches pubspec.yaml', () {
      expect(
          telemetryVersionProblems(
              kAppVersion, File('pubspec.yaml').readAsStringSync()),
          isEmpty);
    });

    test('the code sends only dictionary events, and every one of them', () {
      expect(telemetryTrackCallProblems(lexifyDictionary), isEmpty);
    });

    test('no key, no network', () async {
      expect(await telemetryNoKeyProblems(lexifyDictionary), isEmpty);
    }, skip: const bool.fromEnvironment('TELEMETRY_DEBUG'));

    test('off means nothing', () async {
      expect(await telemetryOffProblems(lexifyDictionary), isEmpty);
    });
  });

  group('catalogue enums', () {
    final decks = [
      for (final f in Directory('assets/decks').listSync())
        if (f is File && f.path.endsWith('.json'))
          jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
    ];

    test('every bundled deck is in kDeckIds', () {
      final slugs = {for (final d in decks) d['deck'] as String};
      expect(slugs.difference(kDeckIds), isEmpty);
    });

    test('every card language of a bundled deck is in kCardLangs', () {
      final langs = {
        for (final d in decks) ...(d['titles'] as Map).keys.cast<String>(),
      };
      expect(langs.difference(kCardLangs), isEmpty);
    });

    test('every UI language is in the dictionary', () {
      expect(
          {for (final l in LexifyApp.supportedLocales) telemetryLocaleId(l)},
          kUiLangs);
    });

    test('unknown values fall back to other', () {
      expect(telemetryDeck('new-deck'), 'other');
      expect(telemetryCardLang('xx'), 'other');
      expect(telemetryStyle('illustrious-new'), 'other');
    });
  });

  group('Android is never measured (Google Play Families policy)', () {
    tearDown(Telemetry.resetForTest);

    test('platform rule', () {
      expect(telemetryAllowedOn(TargetPlatform.android, web: false), isFalse);
      expect(telemetryAllowedOn(TargetPlatform.iOS, web: true), isFalse);
      for (final p in [
        TargetPlatform.iOS,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ]) {
        expect(telemetryAllowedOn(p, web: false), isTrue, reason: '$p');
      }
    });

    test('startTelemetry on Android never calls init, even with a sink',
        () async {
      final store = MemoryTelemetryStore();
      final sink = FakeSink();
      await startTelemetry(
        platform: TargetPlatform.android,
        web: false,
        store: store,
        prefsKeys: () => const [],
        sink: sink,
        startTimer: false,
        observeLifecycle: false,
      );
      expect(Telemetry.isConfigured, isFalse);
      Telemetry.track('deck_view',
          {'deck': 'animals-sea', 'free': false, 'owned': false});
      Telemetry.activation();
      await Telemetry.appQuitting();
      await Telemetry.flush();
      expect(Telemetry.debugQueue, isEmpty);
      expect(sink.sent, isEmpty);
      expect(store.operations, 0);
      expect(
          telemetryToggleVisible(platform: TargetPlatform.android, web: false),
          isFalse);
    });

    test('the same call on iOS measures', () async {
      final store = MemoryTelemetryStore();
      await startTelemetry(
        platform: TargetPlatform.iOS,
        web: false,
        store: store,
        prefsKeys: () => const [],
        sink: FakeSink(),
        startTimer: false,
        observeLifecycle: false,
      );
      expect(Telemetry.isConfigured, isTrue);
      expect(Telemetry.debugQueue.map((e) => e.name), contains('app_open'));
      expect(telemetryToggleVisible(platform: TargetPlatform.iOS, web: false),
          isTrue);
      // A configured engine still never shows the switch on Android.
      expect(
          telemetryToggleVisible(platform: TargetPlatform.android, web: false),
          isFalse);
    });

    testWidgets('settings shows no switch on Android', (tester) async {
      await startTelemetry(
        platform: TargetPlatform.iOS,
        web: false,
        store: MemoryTelemetryStore(),
        prefsKeys: () => const [],
        sink: FakeSink(),
        startTimer: false,
        observeLifecycle: false,
      );
      Future<void> pump() => tester.pumpWidget(const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ));

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pump();
      expect(find.byKey(const ValueKey('telemetry-switch')), findsOneWidget);

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(const SizedBox.shrink());
      await pump();
      expect(find.byKey(const ValueKey('telemetry-switch')), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  test('earlier Lexify data means days_band pre', () {
    expect(hadLexifyData(const []), isFalse);
    expect(hadLexifyData(const ['telemetry_install_day']), isFalse);
    expect(hadLexifyData(const ['card_priorities_animals-sea']), isTrue);
    expect(hadLexifyData(const ['free_decks_seeded_v1']), isTrue);
  });
}
