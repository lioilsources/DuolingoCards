import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String frontLanguage;
  final String backLanguage;
  final List<Flashcard> cards;

  Deck({
    required this.id,
    required this.name,
    required this.frontLanguage,
    required this.backLanguage,
    required this.cards,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      frontLanguage: json['frontLanguage'] as String,
      backLanguage: json['backLanguage'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((card) => Flashcard.fromJson(card as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'frontLanguage': frontLanguage,
      'backLanguage': backLanguage,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }
}
