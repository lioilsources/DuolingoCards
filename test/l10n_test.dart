import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:duolingo_cards/l10n/app_localizations.dart';
import 'package:duolingo_cards/main.dart';
import 'package:duolingo_cards/utils/language_names.dart';

/// App Review rejected 2.2.2 under guideline 4 because one screen showed
/// Czech and English side by side. These tests guard the two ways that comes
/// back: a key missing from one ARB file (gen-l10n silently falls back to
/// English for it) and a hardcoded string in a widget.
void main() {
  Set<String> keysOf(String path) {
    final json = jsonDecode(File(path).readAsStringSync()) as Map;
    return json.keys.cast<String>().where((k) => !k.startsWith('@')).toSet();
  }

  test('the app offers every generated locale, English first', () {
    // basicLocaleListResolution falls back to supportedLocales.first, so the
    // order is behaviour, not style: a German phone must land on English.
    expect(LexifyApp.supportedLocales.first, const Locale('en'));
    expect(LexifyApp.supportedLocales.toSet(),
        AppLocalizations.supportedLocales.toSet());
  });

  test('every locale defines every key of the English template', () {
    final template = keysOf('lib/l10n/app_en.arb');
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == 'en') continue;
      final keys = keysOf('lib/l10n/app_${locale.languageCode}.arb');
      expect(template.difference(keys), isEmpty,
          reason: '${locale.languageCode} is missing keys');
      expect(keys.difference(template), isEmpty,
          reason: '${locale.languageCode} has keys en does not');
    }
  });

  test('no widget carries a hardcoded Czech string', () {
    // Diacritics are a cheap, reliable tell for Czech copy left outside l10n.
    final czech = RegExp('[ěščřžýáíéúůťďňĚŠČŘŽÝÁÍÉÚŮŤĎŇ]');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.contains('${Platform.pathSeparator}l10n${Platform.pathSeparator}')) {
        continue;
      }
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (czech.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty);
  });

  group('lookups', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final cs = lookupAppLocalizations(const Locale('cs'));

    test('resolve per locale', () {
      expect(en.badgeFree, 'Free');
      expect(cs.badgeFree, 'Zdarma');
    });

    test('pluralise card counts in both languages', () {
      expect(en.tileCardsAndPair(1, 'EN', 'ES'), '1 card · EN → ES');
      expect(en.tileCardsAndPair(50, 'EN', 'ES'), '50 cards · EN → ES');
      expect(cs.tileCardsAndPair(1, 'CS', 'DE'), '1 karta · CS → DE');
      expect(cs.tileCardsAndPair(3, 'CS', 'DE'), '3 karty · CS → DE');
      expect(cs.tileCardsAndPair(50, 'CS', 'DE'), '50 karet · CS → DE');
    });

    test('name every shipped language in every UI language', () {
      const shipped = [
        'ar', 'cs', 'de', 'el', 'en', 'es-419', 'fr', 'he', 'hi', 'id', 'ja',
        'ko', 'pt-BR', 'ru', 'tr', 'vi', 'zh-CN',
      ];
      for (final code in shipped) {
        final english = langDisplayName(code, en);
        final czech = langDisplayName(code, cs);
        expect(english, isNot(contains(code)), reason: '$code unnamed in en');
        expect(czech, isNot(contains(code)), reason: '$code unnamed in cs');
        expect(english, isNot(equals(czech)),
            reason: '$code is not translated');
      }
      expect(langDisplayName('de', en), '🇩🇪 German');
      expect(langDisplayName('de', cs), '🇩🇪 Němčina');
    });

    test('an unshipped language falls back to its English entry', () {
      expect(langDisplayName('la', cs), '🏛️ Latin');
      expect(langDisplayName('xx', cs), 'xx');
    });
  });

  group('locale resolution', () {
    // Same delegates and locale list as LexifyApp, minus HomeScreen, which
    // needs platform plugins the test binding does not provide.
    Widget probe(Locale device) => MaterialApp(
          locale: device,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: LexifyApp.supportedLocales,
          home: Builder(
            builder: (context) =>
                Text(AppLocalizations.of(context).storeRestorePurchases),
          ),
        );

    testWidgets('a Czech device gets Czech', (tester) async {
      await tester.pumpWidget(probe(const Locale('cs')));
      await tester.pump();
      expect(find.text('Obnovit nákupy'), findsOneWidget);
    });

    testWidgets('an English device gets English', (tester) async {
      await tester.pumpWidget(probe(const Locale('en', 'US')));
      await tester.pump();
      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('a device language the UI does not ship gets English',
        (tester) async {
      await tester.pumpWidget(probe(const Locale('de')));
      await tester.pump();
      expect(find.text('Restore Purchases'), findsOneWidget);
    });
  });
}
