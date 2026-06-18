import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:path_provider/path_provider.dart';

import '../models/language_deck.dart';

/// Loads no-backend [LanguageDeck]s.
///
/// Priority order for [load]:
///   1. Documents directory (downloaded from CDN via [DeckDownloadService])
///   2. Bundled asset (`assets/decks/<slug>.json`)
class LanguageDeckService {
  LanguageDeckService._();
  static final LanguageDeckService instance = LanguageDeckService._();

  final Map<String, LanguageDeck> _cache = {};

  /// Load deck by slug. Checks docsDir first, falls back to bundled assets.
  Future<LanguageDeck> load(String slug) async {
    final cached = _cache[slug];
    if (cached != null) return cached;

    final docsPath = (await getApplicationDocumentsDirectory()).path;
    final docFile = File('$docsPath/decks/$slug/deck.json');

    final raw = docFile.existsSync()
        ? await docFile.readAsString()
        : await rootBundle.loadString('assets/decks/$slug.json');

    final deck =
        LanguageDeck.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _cache[slug] = deck;
    return deck;
  }

  /// True if the deck is available locally — either downloaded or bundled.
  Future<bool> isAvailableLocally(String slug) async {
    final docsPath = (await getApplicationDocumentsDirectory()).path;
    if (File('$docsPath/decks/$slug/deck.json').existsSync()) return true;
    try {
      await rootBundle.loadString('assets/decks/$slug.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Evict [slug] from the in-memory cache so the next [load] re-reads from disk.
  void invalidateCache(String slug) => _cache.remove(slug);

  /// Discover every bundled deck slug under `assets/decks/`.
  Future<List<String>> availableSlugs() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest
        .listAssets()
        .where((p) => p.startsWith('assets/decks/') && p.endsWith('.json'))
        .map((p) =>
            p.substring('assets/decks/'.length, p.length - '.json'.length))
        .toList()
      ..sort();
  }

  /// Load every bundled deck.
  Future<List<LanguageDeck>> loadAll() async {
    final slugs = await availableSlugs();
    return Future.wait(slugs.map(load));
  }
}
