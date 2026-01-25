import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String? description;
  final String frontLanguage;
  final String backLanguage;
  final List<Flashcard> cards;
  final String? mediaBaseUrl;

  Deck({
    required this.id,
    required this.name,
    this.description,
    required this.frontLanguage,
    required this.backLanguage,
    required this.cards,
    this.mediaBaseUrl,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      frontLanguage: json['frontLanguage'] as String,
      backLanguage: json['backLanguage'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((card) => Flashcard.fromJson(card as Map<String, dynamic>))
          .toList(),
      mediaBaseUrl: json['mediaBaseUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frontLanguage': frontLanguage,
      'backLanguage': backLanguage,
      'cards': cards.map((card) => card.toJson()).toList(),
      'mediaBaseUrl': mediaBaseUrl,
    };
  }

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? frontLanguage,
    String? backLanguage,
    List<Flashcard>? cards,
    String? mediaBaseUrl,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frontLanguage: frontLanguage ?? this.frontLanguage,
      backLanguage: backLanguage ?? this.backLanguage,
      cards: cards ?? this.cards,
      mediaBaseUrl: mediaBaseUrl ?? this.mediaBaseUrl,
    );
  }

  /// Resolves relative media paths using mediaBaseUrl.
  /// If mediaBaseUrl is set and media paths are relative, they will be prefixed.
  Deck withResolvedMediaUrls() {
    if (mediaBaseUrl == null || mediaBaseUrl!.isEmpty) {
      return this;
    }

    final resolvedCards = cards
        .map((card) => card.withResolvedMediaUrls(mediaBaseUrl!))
        .toList();

    return copyWith(cards: resolvedCards);
  }
}
