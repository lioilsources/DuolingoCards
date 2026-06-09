import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;

import '../models/language_deck.dart';

/// Loads no-backend [LanguageDeck]s bundled in the app (distribution variant B:
/// all deck.json files ship in the binary under `assets/decks/`). No network,
/// no local file copies — the JSON is read straight from the asset bundle.
class LanguageDeckService {
  LanguageDeckService._();
  static final LanguageDeckService instance = LanguageDeckService._();

  final Map<String, LanguageDeck> _cache = {};

  /// Load one deck by slug from `assets/decks/<slug>.json`.
  Future<LanguageDeck> load(String slug) async {
    final cached = _cache[slug];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/decks/$slug.json');
    final deck =
        LanguageDeck.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _cache[slug] = deck;
    return deck;
  }

  /// Discover every bundled deck slug under `assets/decks/`.
  Future<List<String>> availableSlugs() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest
        .listAssets()
        .where((p) => p.startsWith('assets/decks/') && p.endsWith('.json'))
        .map((p) => p.substring('assets/decks/'.length, p.length - '.json'.length))
        .toList()
      ..sort();
  }

  /// Load every bundled deck.
  Future<List<LanguageDeck>> loadAll() async {
    final slugs = await availableSlugs();
    return Future.wait(slugs.map(load));
  }
}
