import 'package:flutter/widgets.dart';

/// Text-direction helpers for the 20 target languages.
///
/// Card text is rendered in whatever language is on that side, so direction is
/// per-string, not per-app: wrap label/summary/info in a [Directionality] using
/// [directionFor] (see [DirectionalText]).
class LocaleDirection {
  LocaleDirection._();

  /// Base language codes that use a right-to-left script.
  static const Set<String> rtlBase = {'ar', 'ur', 'fa', 'he'};

  /// All target language codes from the plan (top 20).
  static const List<String> targets = [
    'en', 'zh-CN', 'hi', 'es-419', 'ar', 'fr', 'bn', 'pt-BR', 'ru', 'id',
    'ur', 'de', 'ja', 'mr', 'te', 'tr', 'ta', 'vi', 'ko', 'ha',
  ];

  /// True when [lang] (BCP-47, region tolerated) is right-to-left.
  static bool isRtl(String lang) => rtlBase.contains(_base(lang));

  /// [TextDirection] for [lang].
  static TextDirection directionFor(String lang) =>
      isRtl(lang) ? TextDirection.rtl : TextDirection.ltr;

  static String _base(String lang) {
    final i = lang.indexOf('-');
    return i == -1 ? lang : lang.substring(0, i);
  }
}

/// Renders [text] with the correct direction for [lang]. Use anywhere a card
/// shows language content so Arabic/Urdu lay out right-to-left.
class DirectionalText extends StatelessWidget {
  final String text;
  final String lang;
  final TextStyle? style;
  final TextAlign? textAlign;

  const DirectionalText(
    this.text, {
    super.key,
    required this.lang,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocaleDirection.directionFor(lang),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
