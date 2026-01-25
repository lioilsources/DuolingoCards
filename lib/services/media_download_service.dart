import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class MediaDownloadService {
  final Dio _dio;

  MediaDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Downloads all media for a deck and returns a new deck with local file paths.
  /// [onProgress] callback receives (downloaded, total) counts.
  Future<Deck> downloadDeckMedia(
    Deck deck, {
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final basePath = await _localPath;
    final mediaDir = Directory('$basePath/decks/${deck.id}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    // Collect all media URLs that need downloading
    final mediaUrls = <String, String>{}; // url -> local filename
    for (final card in deck.cards) {
      final media = card.media;
      if (media == null) continue;

      if (media.image != null && media.image!.startsWith('http')) {
        final filename = _extractFilename(media.image!);
        mediaUrls[media.image!] = filename;
      }
      if (media.audioFront != null && media.audioFront!.startsWith('http')) {
        final filename = _extractFilename(media.audioFront!);
        mediaUrls[media.audioFront!] = filename;
      }
      if (media.audioBack != null && media.audioBack!.startsWith('http')) {
        final filename = _extractFilename(media.audioBack!);
        mediaUrls[media.audioBack!] = filename;
      }
      if (media.video != null && media.video!.startsWith('http')) {
        final filename = _extractFilename(media.video!);
        mediaUrls[media.video!] = filename;
      }
    }

    final total = mediaUrls.length;
    var downloaded = 0;

    // Download all media files
    final urlToLocalPath = <String, String>{};
    for (final entry in mediaUrls.entries) {
      final url = entry.key;
      final filename = entry.value;
      final localPath = '${mediaDir.path}/$filename';

      try {
        // Check if file already exists
        if (!await File(localPath).exists()) {
          await _dio.download(url, localPath);
        }
        urlToLocalPath[url] = localPath;
      } catch (e) {
        // If download fails, keep the original URL
        urlToLocalPath[url] = url;
      }

      downloaded++;
      onProgress?.call(downloaded, total);
    }

    // Create new deck with local paths
    final updatedCards = deck.cards.map((card) {
      if (card.media == null) return card;

      final media = card.media!;
      return card.copyWith(
        media: CardMedia(
          image: urlToLocalPath[media.image] ?? media.image,
          audioFront: urlToLocalPath[media.audioFront] ?? media.audioFront,
          audioBack: urlToLocalPath[media.audioBack] ?? media.audioBack,
          video: urlToLocalPath[media.video] ?? media.video,
        ),
      );
    }).toList();

    return deck.copyWith(cards: updatedCards);
  }

  String _extractFilename(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    // Fallback: generate filename from hash
    return '${url.hashCode}';
  }

  /// Deletes all downloaded media for a deck.
  Future<void> deleteDeckMedia(String deckId) async {
    final basePath = await _localPath;
    final mediaDir = Directory('$basePath/decks/$deckId/media');
    if (await mediaDir.exists()) {
      await mediaDir.delete(recursive: true);
    }
  }
}
