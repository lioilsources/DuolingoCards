import 'prioritizable_card.dart';

/// No-backend "language deck" model — the v2 learning-card format produced by
/// the content pipeline (`content build` → deck.json).
///
/// Unlike the legacy quiz `Deck`/`Flashcard`, every concept carries three
/// learning fields (`label`, `summary`, `info`) in all target languages, so a
/// single deck serves any native→foreign language pairing.
///
/// Display logic for a pair (native L1 → foreign L2):
///   • foreign side: [LanguageCard.foreignLabel] + [LanguageCard.foreignSummary]
///   • native  side: [LanguageCard.nativeLabel]  + [LanguageCard.nativeInfo]
class LanguageDeck {
  final String slug;
  final int version;
  final int tier;
  final List<String> styles;
  final String defaultStyle;
  final Map<String, String> titles; // lang → deck title
  final List<LanguageCard> cards;

  const LanguageDeck({
    required this.slug,
    required this.version,
    this.tier = 0,
    this.styles = const [],
    required this.defaultStyle,
    required this.titles,
    required this.cards,
  });

  /// Deck title in [lang], falling back to English then the first available.
  String title(String lang) {
    return titles[lang] ??
        titles[_baseLang(lang)] ??
        titles['en'] ??
        (titles.isNotEmpty ? titles.values.first : slug);
  }

  /// Languages for which this deck has at least a title.
  List<String> get availableLanguages => titles.keys.toList();

  factory LanguageDeck.fromJson(Map<String, dynamic> json) {
    return LanguageDeck(
      slug: json['deck'] as String,
      version: json['version'] as int? ?? 1,
      tier: json['tier'] as int? ?? 0,
      styles:
          (json['styles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      defaultStyle: json['defaultStyle'] as String? ?? '',
      titles: _stringMap(json['titles']),
      cards: (json['cards'] as List<dynamic>? ?? const [])
          .map((c) => LanguageCard.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One concept with per-language `label`, `summary` and `info`.
class LanguageCard implements PrioritizableCard {
  final String key;
  final String image;
  final Map<String, String> label;
  final Map<String, String> summary;
  final Map<String, String> info;

  @override
  String get priorityId => key;

  @override
  int priority;

  @override
  DateTime? lastSeen;

  LanguageCard({
    required this.key,
    required this.image,
    required this.label,
    required this.summary,
    required this.info,
    this.priority = 5,
    this.lastSeen,
  });

  @override
  void increasePriority() {
    if (priority < 10) priority++;
    lastSeen = DateTime.now();
  }

  @override
  void decreasePriority() {
    if (priority > 1) priority--;
    lastSeen = DateTime.now();
  }

  /// Word shown on the foreign side (the language being learned).
  String? foreignLabel(String l2) => _pick(label, l2);

  /// Gloss shown on the foreign side, in the foreign language.
  String? foreignSummary(String l2) => _pick(summary, l2);

  /// Word shown on the native side (the learner's own language).
  String? nativeLabel(String l1) => _pick(label, l1);

  /// Full learning text shown on the native side, in the native language.
  String? nativeInfo(String l1) => _pick(info, l1);

  /// True when both sides of a native→foreign pair can be rendered.
  bool supportsPair(String l1, String l2) =>
      foreignLabel(l2) != null && nativeLabel(l1) != null;

  factory LanguageCard.fromJson(Map<String, dynamic> json) {
    return LanguageCard(
      key: json['key'] as String,
      image: json['image'] as String? ?? '',
      label: _stringMap(json['label']),
      summary: _stringMap(json['summary']),
      info: _stringMap(json['info']),
    );
  }
}

/// Resolve a value from a per-language map, tolerating regional variants
/// (e.g. `es-419` falls back to `es`, and vice versa).
String? _pick(Map<String, String> m, String lang) {
  final exact = m[lang];
  if (exact != null && exact.isNotEmpty) return exact;
  final base = _baseLang(lang);
  // Exact base match (es-419 → es).
  final baseMatch = m[base];
  if (baseMatch != null && baseMatch.isNotEmpty) return baseMatch;
  // Any regional variant of the same base (es → es-419).
  for (final entry in m.entries) {
    if (_baseLang(entry.key) == base && entry.value.isNotEmpty) {
      return entry.value;
    }
  }
  return null;
}

String _baseLang(String lang) {
  final i = lang.indexOf('-');
  return i == -1 ? lang : lang.substring(0, i);
}

Map<String, String> _stringMap(dynamic raw) {
  if (raw is! Map) return const {};
  return raw.map((k, v) => MapEntry(k as String, v as String));
}
