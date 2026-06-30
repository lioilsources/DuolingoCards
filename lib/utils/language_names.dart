/// Shared language display names with flag emoji, keyed by BCP-47 code.
///
/// Used by language pickers throughout the app. Falls back to the raw code
/// when a language is not listed here.
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
