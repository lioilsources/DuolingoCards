import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/cdn_config.dart';

class DeckDownloadService {
  static final DeckDownloadService instance = DeckDownloadService._();
  DeckDownloadService._();

  /// Download full deck (deck.json + all images for [style]) from CDN.
  ///
  /// [onProgress] receives values from 0.0 to 1.0 as images are saved.
  /// Returns true on success, false if the JSON download fails.
  Future<bool> downloadDeck(
    String slug,
    String style, {
    void Function(double progress)? onProgress,
  }) async {
    final docsPath = (await getApplicationDocumentsDirectory()).path;
    final deckDir = '$docsPath/decks/$slug';
    final imagesDir = '$deckDir/images/$style';

    await Directory(imagesDir).create(recursive: true);

    // 1. Download and save deck.json
    final deckJsonUrl = '$kCdnBaseUrl/decks/$slug/deck.json';
    final jsonResponse = await _get(deckJsonUrl);
    if (jsonResponse == null) return false;
    await File('$deckDir/deck.json').writeAsBytes(jsonResponse);

    // 2. Extract image filenames
    final deckData =
        jsonDecode(utf8.decode(jsonResponse)) as Map<String, dynamic>;
    final images = (deckData['cards'] as List<dynamic>? ?? [])
        .map((c) => (c as Map<String, dynamic>)['image'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // 3. Download each image
    for (var i = 0; i < images.length; i++) {
      final imgPath = '$imagesDir/${images[i]}';
      if (!File(imgPath).existsSync()) {
        final imgUrl = '$kCdnBaseUrl/decks/$slug/images/$style/${images[i]}';
        final bytes = await _get(imgUrl);
        if (bytes != null) await File(imgPath).writeAsBytes(bytes);
      }
      onProgress?.call((i + 1) / images.length);
    }

    return true;
  }

  /// True when deck.json exists in the documents directory for [slug].
  Future<bool> isDownloaded(String slug) async {
    final docsPath = (await getApplicationDocumentsDirectory()).path;
    return File('$docsPath/decks/$slug/deck.json').existsSync();
  }

  Future<List<int>?> _get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }
}
