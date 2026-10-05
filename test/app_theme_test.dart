import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:duolingo_cards/theme/app_theme.dart';
import 'package:duolingo_cards/utils/locale_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) =>
    MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));

TextStyle _styleOf(WidgetTester tester, String text) {
  final rich = tester.widget<RichText>(find.descendant(
      of: find.text(text), matching: find.byType(RichText)));
  return rich.text.style!;
}

void main() {
  testWidgets('every Material text slot uses a kid face', (tester) async {
    late TextTheme theme;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      theme = Theme.of(context).textTheme;
      return const SizedBox();
    })));
    final slots = {
      'displayLarge': theme.displayLarge, 'displayMedium': theme.displayMedium,
      'displaySmall': theme.displaySmall, 'headlineLarge': theme.headlineLarge,
      'headlineMedium': theme.headlineMedium,
      'headlineSmall': theme.headlineSmall, 'titleLarge': theme.titleLarge,
      'titleMedium': theme.titleMedium, 'titleSmall': theme.titleSmall,
      'bodyLarge': theme.bodyLarge, 'bodyMedium': theme.bodyMedium,
      'bodySmall': theme.bodySmall, 'labelLarge': theme.labelLarge,
      'labelMedium': theme.labelMedium, 'labelSmall': theme.labelSmall,
    };
    slots.forEach((name, style) {
      expect(style!.fontFamily, startsWith('packages/cute_kid_fonts/'),
          reason: name);
      expect(style.fontSize, isNotNull, reason: '$name lost its size');
    });
    expect(theme.titleLarge!.fontFamily, KidFonts.dynaPuff);
    expect(theme.bodyMedium!.fontFamily, KidFonts.baloo2);
  });

  testWidgets('an ad-hoc TextStyle inherits the kid face', (tester) async {
    await tester.pumpWidget(
        _app(const Text('Ahoj', style: TextStyle(fontSize: 18))));
    expect(_styleOf(tester, 'Ahoj').fontFamily, KidFonts.baloo2);
  });

  // The regression this guards: a `wght` variation in the theme outranks
  // fontWeight and is inherited, which turned every bold label regular.
  testWidgets('FontWeight.bold is actually wider than regular',
      (tester) async {
    await tester.pumpWidget(_app(const Column(children: [
      Text('Hamburgefonstiv', style: TextStyle(fontSize: 30)),
      Text('Hamburgefonstiv',
          key: Key('bold'),
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    ])));
    final regular = tester.getSize(find.byType(Text).first).width;
    final bold = tester.getSize(find.byKey(const Key('bold'))).width;
    expect(bold, greaterThan(regular));
  });

  group('card content is drawn in one face', () {
    Future<TextStyle> content(WidgetTester tester, String text, String lang,
        {bool title = false}) async {
      await tester.pumpWidget(_app(Builder(
        builder: (context) => DirectionalText(text,
            lang: lang,
            style: title ? Theme.of(context).textTheme.headlineMedium : null),
      )));
      return _styleOf(tester, text);
    }

    testWidgets('Czech keeps the theme face', (tester) async {
      expect((await content(tester, 'Příliš žluťoučký', 'cs', title: true))
          .fontFamily, KidFonts.dynaPuff);
    });

    testWidgets('Vietnamese titles move to Baloo 2 as a whole',
        (tester) async {
      expect((await content(tester, 'Thổ Nhĩ Kỳ', 'vi', title: true))
          .fontFamily, KidFonts.baloo2);
    });

    testWidgets('Cyrillic moves to Nunito', (tester) async {
      expect((await content(tester, 'Россия', 'ru')).fontFamily,
          KidFonts.nunito);
    });

    testWidgets('Hindi stays in Baloo 2', (tester) async {
      expect((await content(tester, 'भारत', 'hi')).fontFamily,
          KidFonts.baloo2);
    });

    testWidgets('Greek leaves the kid faces, fallback included',
        (tester) async {
      final style = await content(tester, 'Ελλάδα μπ', 'el', title: true);
      expect(style.fontFamily, isNot(startsWith('packages/cute_kid_fonts/')));
      expect(style.fontFamilyFallback, isEmpty);
    });
  });
}
