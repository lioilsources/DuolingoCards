import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:path_provider/path_provider.dart';

import '../models/language_deck.dart';

/// Loads no-backend [LanguageDeck]s.
///
/// A deck can exist twice: bundled in the app binary, and downloaded from the
/// CDN into the documents directory. [load] takes whichever declares the
/// higher `version`, and the bundled copy wins a tie.
///
/// Preferring the download unconditionally — what this did before — meant a
/// deck downloaded by an older build kept overriding the app forever. When the
/// image styles were renamed, devices carried on offering the vanished
/// `flux-real` and `pony-cartoon`, drawing placeholders for images that no
/// longer existed under those names. Nothing invalidated that copy, because
/// nothing was comparing the two.
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

    LanguageDeck? downloaded;
    if (docFile.existsSync()) {
      try {
        downloaded = LanguageDeck.fromJson(
            jsonDecode(await docFile.readAsString()) as Map<String, dynamic>);
      } catch (_) {
        // A truncated download must not make the deck unopenable.
      }
    }

    LanguageDeck? bundled;
    try {
      bundled = LanguageDeck.fromJson(
          jsonDecode(await rootBundle.loadString('assets/decks/$slug.json'))
              as Map<String, dynamic>);
    } catch (_) {
      // Deck delivered purely over the air; the download is all there is.
    }

    final deck = newerOf(bundled, downloaded);
    if (deck == null) {
      throw StateError('deck $slug is neither bundled nor downloaded');
    }
    _cache[slug] = deck;
    return deck;
  }

  /// The deck with the higher version. Ties go to [bundled], which ships with
  /// the code that reads it and so cannot disagree with the app about styles.
  @visibleForTesting
  static LanguageDeck? newerOf(LanguageDeck? bundled, LanguageDeck? downloaded) {
    if (bundled == null) return downloaded;
    if (downloaded == null) return bundled;
    return downloaded.version > bundled.version ? downloaded : bundled;
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
