class CatalogItem {
  final String id;
  final String name;
  final String description;
  final int cardCount;
  final String price; // "free" or "tier1", "tier2", etc.
  final String? iapProductId;
  final String? thumbnailUrl;
  final List<String> languages;

  CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.price,
    this.iapProductId,
    this.thumbnailUrl,
    required this.languages,
  });

  bool get isFree => price == 'free';

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      cardCount: json['cardCount'] as int,
      price: json['price'] as String,
      iapProductId: json['iapProductId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class Catalog {
  final List<CatalogItem> decks;

  Catalog({required this.decks});

  factory Catalog.fromJson(Map<String, dynamic> json) {
    return Catalog(
      decks: (json['decks'] as List<dynamic>)
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DeckPreview {
  final String id;
  final String name;
  final String description;
  final String frontLanguage;
  final String backLanguage;
  final int totalCards;
  final List<Map<String, dynamic>> previewCards;

  DeckPreview({
    required this.id,
    required this.name,
    required this.description,
    required this.frontLanguage,
    required this.backLanguage,
    required this.totalCards,
    required this.previewCards,
  });

  factory DeckPreview.fromJson(Map<String, dynamic> json) {
    return DeckPreview(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      frontLanguage: json['frontLanguage'] as String,
      backLanguage: json['backLanguage'] as String,
      totalCards: json['totalCards'] as int,
      previewCards: (json['previewCards'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}
