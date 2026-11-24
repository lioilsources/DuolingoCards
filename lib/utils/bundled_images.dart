import 'package:flutter/services.dart';

import '../models/language_deck.dart';

/// Where a bundled card picture lives in the app binary.
///
/// Every deck bundles its first few cards per style here (the store preview);
/// a free deck bundles its default style whole (`content publish` reads the
/// free list from `assets/catalog.json`), so it is on home from first launch.
String bundledImagePath(String slug, String style, String image) =>
    'assets/previews/$slug/$style/$image';

/// True when every picture of [deck] in [style] ships in the binary.
///
/// Probes the last card: previews are the leading cards, so only a full set
/// bundles the last one.
Future<bool> isFullyBundled(
  LanguageDeck deck,
  String style, {
  AssetBundle? bundle,
}) async {
  if (deck.cards.isEmpty) return false;
  final image = deck.cards.last.image;
  if (image.isEmpty) return false;
  try {
    await (bundle ?? rootBundle).load(
      bundledImagePath(deck.slug, style, image),
    );
    return true;
  } catch (_) {
    return false;
  }
}
