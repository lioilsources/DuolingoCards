import 'package:cute_kid_fonts/cute_kid_fonts.dart';
import 'package:flutter/material.dart';

/// The app's one theme, and the one place that knows about typefaces.
///
/// Every text style comes from `cute_kid_fonts`: titles in DynaPuff, everything
/// else in Baloo 2. No widget names a font family — a `TextStyle(fontSize: 18)`
/// inherits the face from here, so the whole app changes typeface in one edit.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: KidTextTheme.apply(base.textTheme),
      primaryTextTheme: KidTextTheme.apply(base.primaryTextTheme),
    );
  }

  static const _kidFamilies = {
    KidFonts.dynaPuff,
    KidFonts.baloo2,
    KidFonts.nunito,
    KidFonts.grandstanderItalic,
  };

  /// [style] adjusted so that [text] is drawn in a single typeface.
  ///
  /// The theme cannot see the text, and card content comes in thirty
  /// languages. DynaPuff has no Vietnamese tone marks and no Cyrillic; Baloo 2
  /// has one stray Greek letter. Left to per-glyph fallback, a Vietnamese title
  /// alternates between two faces inside one word. So content picks the first
  /// kid face that covers the whole string, and for scripts none of them draws
  /// (Greek, Hebrew, Arabic, CJK) leaves the kid faces entirely for the
  /// platform font.
  static TextStyle? forContent(
      BuildContext context, TextStyle? style, String text) {
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final current = effective.fontFamily;
    if (current == null || !_kidFamilies.contains(current)) return style;

    final family = KidFonts.firstCovering(text, current);
    if (family == current) return style;
    if (family != null) {
      return (style ?? const TextStyle()).copyWith(fontFamily: family);
    }
    final system = Typography.material2021(platform: Theme.of(context).platform)
        .black
        .bodyMedium
        ?.fontFamily;
    return (style ?? const TextStyle())
        .copyWith(fontFamily: system, fontFamilyFallback: const []);
  }
}
