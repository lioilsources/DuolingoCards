import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/deck.dart';

class DeckService {
  Future<Deck> loadDeck(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return Deck.fromJson(jsonData);
  }

  Future<Deck> loadJapaneseBasics() async {
    return loadDeck('assets/data/japanese_basics.json');
  }
}
