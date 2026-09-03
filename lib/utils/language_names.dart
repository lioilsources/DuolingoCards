import '../l10n/app_localizations.dart';

/// English language display names with flag emoji, keyed by BCP-47 code.
///
/// This is the fallback table: pickers show [langDisplayName], which names the
/// 17 shipped languages in the UI language and only reaches for this map for
/// codes the UI has no word for.
const kLangNames = <String, String>{
  // Pivot / authoring language
  'cs': '🇨🇿 Czech',

  // Original top-20 targets
  'en': '🇬🇧 English',
  'zh-CN': '🇨🇳 Chinese',
  'hi': '🇮🇳 Hindi',
  'es-419': '🇲🇽 Spanish',
  'ar': '🇸🇦 Arabic',
  'fr': '🇫🇷 French',
  'bn': '🇧🇩 Bengali',
  'pt-BR': '🇧🇷 Portuguese',
  'ru': '🇷🇺 Russian',
  'id': '🇮🇩 Indonesian',
  'ur': '🇵🇰 Urdu',
  'de': '🇩🇪 German',
  'ja': '🇯🇵 Japanese',
  'mr': '🇮🇳 Marathi',
  'te': '🇮🇳 Telugu',
  'tr': '🇹🇷 Turkish',
  'ta': '🇱🇰 Tamil',
  'vi': '🇻🇳 Vietnamese',
  'ko': '🇰🇷 Korean',
  'ha': '🇳🇬 Hausa',

  // Classical / constructed
  'la': '🏛️ Latin',
  'sa': '🕉️ Sanskrit',
  'eo': '🌍 Esperanto',

  // Middle East & South Caucasus
  'el': '🇬🇷 Greek',
  'he': '🇮🇱 Hebrew',
  'fa': '🇮🇷 Persian',
  'yi': '🇮🇱 Yiddish',
  'az': '🇦🇿 Azerbaijani',
  'hy': '🇦🇲 Armenian',
  'ka': '🇬🇪 Georgian',

  // East Europe & Balkans
  'pl': '🇵🇱 Polish',
  'sk': '🇸🇰 Slovak',
  'hu': '🇭🇺 Hungarian',
  'ro': '🇷🇴 Romanian',
  'bg': '🇧🇬 Bulgarian',
  'uk': '🇺🇦 Ukrainian',
  'be': '🇧🇾 Belarusian',
  'sr': '🇷🇸 Serbian',
  'hr': '🇭🇷 Croatian',
  'sl': '🇸🇮 Slovenian',
  'bs': '🇧🇦 Bosnian',
  'mk': '🇲🇰 Macedonian',
  'sq': '🇽🇰 Albanian',

  // West & North Europe
  'nl': '🇳🇱 Dutch',
  'nl-BE': '🇧🇪 Flemish',
  'da': '🇩🇰 Danish',
  'nb': '🇳🇴 Norwegian',
  'sv': '🇸🇪 Swedish',
  'fi': '🇫🇮 Finnish',
  'is': '🇮🇸 Icelandic',
  'mt': '🇲🇹 Maltese',

  // Baltic
  'lt': '🇱🇹 Lithuanian',
  'lv': '🇱🇻 Latvian',
  'et': '🇪🇪 Estonian',

  // Celtic
  'ga': '🇮🇪 Irish',
  'cy': '🏴󠁧󠁢󠁷󠁬󠁳󠁿 Welsh',

  // World-coverage gap-fillers (large countries to complete the map)
  'it': '🇮🇹 Italian',
  'am': '🇪🇹 Amharic',
  'ne': '🇳🇵 Nepali',
  'uz': '🇺🇿 Uzbek',
  'tk': '🇹🇲 Turkmen',
  'mn': '🇲🇳 Mongolian',
  'th': '🇹🇭 Thai',
  'my': '🇲🇲 Burmese',
  'km': '🇰🇭 Khmer',
  'lo': '🇱🇦 Lao',
  'ms': '🇲🇾 Malay',
};

/// The flag emoji [kLangNames] carries for [code], or null when the language
/// has no entry. The name is stored as "🇩🇪 German", so the flag is everything
/// before the first space.
String? langFlag(String code) {
  final name = kLangNames[code];
  if (name == null) return null;
  final space = name.indexOf(' ');
  if (space <= 0) return null;
  final flag = name.substring(0, space);
  // Regional-indicator pairs only; a name that starts with a plain word has no
  // flag to give.
  return flag.runes.every((r) => r >= 0x1F1E6 && r <= 0x1F1FF) ? flag : null;
}

/// Display name for [code] in the UI language, with its flag when it has one:
/// "🇩🇪 German" on an English device, the Czech name on a Czech one.
///
/// Codes the UI cannot name fall back to the English entry in [kLangNames],
/// then to the raw code, so a picker never shows an empty item.
String langDisplayName(String code, AppLocalizations l10n) {
  final localized = _localizedName(code, l10n);
  if (localized == null) return kLangNames[code] ?? code;
  final flag = langFlag(code);
  return flag == null ? localized : '$flag $localized';
}

/// The 17 languages every deck ships in. Keep in step with the ARB files.
String? _localizedName(String code, AppLocalizations l10n) => switch (code) {
      'ar' => l10n.langAr,
      'cs' => l10n.langCs,
      'de' => l10n.langDe,
      'el' => l10n.langEl,
      'en' => l10n.langEn,
      'es-419' => l10n.langEs419,
      'fr' => l10n.langFr,
      'he' => l10n.langHe,
      'hi' => l10n.langHi,
      'id' => l10n.langId,
      'ja' => l10n.langJa,
      'ko' => l10n.langKo,
      'pt-BR' => l10n.langPtBR,
      'ru' => l10n.langRu,
      'tr' => l10n.langTr,
      'vi' => l10n.langVi,
      'zh-CN' => l10n.langZhCN,
      _ => null,
    };
