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
}
