import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/deck.dart';

class DeckService {
  // List of bundled asset paths
  static const List<String> bundledAssets = [
    'assets/data/japanese_basics.json',
    'assets/data/japanese-50-animals.json',
    'assets/data/english-50-animals.json',
  ];

  Future<Deck> loadDeck(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final deck = Deck.fromJson(jsonData);
    // Resolve relative media paths to full asset paths
    return deck.withResolvedMediaUrls();
  }

  Future<Deck> loadJapaneseBasics() async {
    return loadDeck('assets/data/japanese_basics.json');
  }

  Future<List<Deck>> loadAllBundledDecks() async {
    final decks = <Deck>[];
    for (final assetPath in bundledAssets) {
      try {
        final deck = await loadDeck(assetPath);
        decks.add(deck);
      } catch (e) {
        // Skip invalid decks
      }
    }
    return decks;
  }
}
