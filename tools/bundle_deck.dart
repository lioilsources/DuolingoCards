// Bundle a backend deck into the mobile app's assets folder
// Usage: dart run tools/bundle_deck.dart <deck-id>
// Example: dart run tools/bundle_deck.dart japanese-basics
//
// This script:
// 1. Reads deck from backend/media/decks/{deckId}.json
// 2. Converts media URLs to relative paths
// 3. Copies media files to assets/media/{deckId}/
// 4. Saves bundled JSON to assets/data/{deckId}.json
// 5. Updates pubspec.yaml with new asset folder
// 6. Updates DeckService with new bundled asset

import 'dart:convert';
import 'dart:io';

const backendDecksDir = 'backend/media/decks';
const backendMediaDir = 'backend/media';
const assetsDataDir = 'assets/data';
const assetsMediaDir = 'assets/media';
const pubspecPath = 'pubspec.yaml';
const deckServicePath = 'lib/services/deck_service.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run tools/bundle_deck.dart <deck-id>');
    print('Example: dart run tools/bundle_deck.dart japanese-basics');
    exit(1);
  }

  final deckId = args[0];
  print('=== Bundling deck: $deckId ===\n');

  try {
    // 1. Load backend deck
    final backendDeck = await loadBackendDeck(deckId);
    print('[1/6] Loaded backend deck: ${backendDeck['name']} (${(backendDeck['cards'] as List).length} cards)');

    // 2. Transform deck for bundling
    final bundledDeck = transformDeck(backendDeck, deckId);
    print('[2/6] Transformed deck (URLs -> relative paths)');

    // 3. Copy media files
    final mediaCount = await copyMediaFiles(deckId);
    print('[3/6] Copied $mediaCount media files');

    // 4. Save bundled JSON
    await saveBundledDeck(bundledDeck, deckId);
    print('[4/6] Saved bundled JSON to $assetsDataDir/$deckId.json');

    // 5. Update pubspec.yaml
    final pubspecUpdated = await updatePubspec(deckId);
    if (pubspecUpdated) {
      print('[5/6] Updated pubspec.yaml with new asset folder');
    } else {
      print('[5/6] pubspec.yaml already contains asset folder (skipped)');
    }

    // 6. Update DeckService
    final serviceUpdated = await updateDeckService(deckId);
    if (serviceUpdated) {
      print('[6/6] Updated DeckService with new bundled asset');
    } else {
      print('[6/6] DeckService already contains bundled asset (skipped)');
    }

    print('\n=== Bundling complete! ===');
    print('\nNext steps:');
    print('  1. Run: flutter pub get');
    print('  2. Run: dart run tools/verify_flashcards.dart');
    print('  3. Test: flutter run');
  } catch (e) {
    print('\nERROR: $e');
    exit(1);
  }
}

/// Load deck JSON from backend
Future<Map<String, dynamic>> loadBackendDeck(String deckId) async {
  final path = '$backendDecksDir/$deckId.json';
  final file = File(path);

  if (!await file.exists()) {
    throw Exception('Backend deck not found: $path');
  }

  final content = await file.readAsString();
  return jsonDecode(content) as Map<String, dynamic>;
}

/// Transform deck: convert URLs to relative paths, set mediaBaseUrl
Map<String, dynamic> transformDeck(Map<String, dynamic> deck, String deckId) {
  final transformed = Map<String, dynamic>.from(deck);

  // Set mediaBaseUrl to asset path
  transformed['mediaBaseUrl'] = '$assetsMediaDir/$deckId';

  // Remove backend-only fields
  transformed.remove('price');
  transformed.remove('version');
  transformed.remove('imagePromptTemplate');

  // Transform card media URLs to relative filenames
  final cards = (transformed['cards'] as List).map((card) {
    final cardMap = Map<String, dynamic>.from(card as Map<String, dynamic>);
    final media = cardMap['media'] as Map<String, dynamic>?;

    if (media != null) {
      final transformedMedia = Map<String, dynamic>.from(media);

      // Extract filename from URL
      if (transformedMedia['image'] != null) {
        transformedMedia['image'] = extractFilename(transformedMedia['image'] as String);
      }
      if (transformedMedia['audioFront'] != null) {
        transformedMedia['audioFront'] = extractFilename(transformedMedia['audioFront'] as String);
      }
      if (transformedMedia['audioBack'] != null) {
        transformedMedia['audioBack'] = extractFilename(transformedMedia['audioBack'] as String);
      }

      cardMap['media'] = transformedMedia;
    }

    return cardMap;
  }).toList();

  transformed['cards'] = cards;
  return transformed;
}

/// Extract filename from URL (e.g., "http://.../01-pes-image.png" -> "01-pes-image.png")
String extractFilename(String urlOrPath) {
  final uri = Uri.tryParse(urlOrPath);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }
  // Already a filename
  return urlOrPath.split('/').last;
}

/// Copy media files from backend to assets
Future<int> copyMediaFiles(String deckId) async {
  final sourceDir = Directory('$backendMediaDir/$deckId');
  final targetDir = Directory('$assetsMediaDir/$deckId');

  if (!await sourceDir.exists()) {
    throw Exception('Backend media folder not found: ${sourceDir.path}');
  }

  // Create target directory
  await targetDir.create(recursive: true);

  int count = 0;
  await for (final entity in sourceDir.list()) {
    if (entity is File) {
      final filename = entity.path.split('/').last;
      // Only copy media files (images and audio)
      if (filename.endsWith('.png') ||
          filename.endsWith('.jpg') ||
          filename.endsWith('.jpeg') ||
          filename.endsWith('.mp3') ||
          filename.endsWith('.wav')) {
        final targetPath = '${targetDir.path}/$filename';
        await entity.copy(targetPath);
        count++;
      }
    }
  }

  return count;
}

/// Save transformed deck to assets/data
Future<void> saveBundledDeck(Map<String, dynamic> deck, String deckId) async {
  final dir = Directory(assetsDataDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File('$assetsDataDir/$deckId.json');
  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(deck));
}

/// Update pubspec.yaml to include new asset folder
Future<bool> updatePubspec(String deckId) async {
  final file = File(pubspecPath);
  var content = await file.readAsString();

  final assetEntry = '    - $assetsMediaDir/$deckId/';

  // Check if already exists
  if (content.contains(assetEntry) || content.contains('$assetsMediaDir/$deckId/')) {
    return false;
  }

  // Find the assets section and add new entry
  // Look for pattern like "    - assets/media/something/"
  final assetPattern = RegExp(r'(\n    - assets/media/[^\n]+/)');
  final matches = assetPattern.allMatches(content).toList();

  if (matches.isNotEmpty) {
    // Add after the last assets/media/ entry
    final lastMatch = matches.last;
    final insertPos = lastMatch.end;
    content = content.substring(0, insertPos) +
        '\n$assetEntry' +
        content.substring(insertPos);
  } else {
    // Look for assets/data/ entry and add after it
    final dataPattern = RegExp(r'(\n    - assets/data/)');
    final dataMatch = dataPattern.firstMatch(content);
    if (dataMatch != null) {
      final insertPos = dataMatch.end;
      content = content.substring(0, insertPos) +
          '\n$assetEntry' +
          content.substring(insertPos);
    } else {
      throw Exception('Could not find assets section in pubspec.yaml');
    }
  }

  await file.writeAsString(content);
  return true;
}

/// Update DeckService to include new bundled asset
Future<bool> updateDeckService(String deckId) async {
  final file = File(deckServicePath);
  var content = await file.readAsString();

  // Convert deck-id to filename (could be deck-id.json or deck_id.json)
  final assetPath = '$assetsDataDir/$deckId.json';

  // Check if already exists
  if (content.contains(assetPath)) {
    return false;
  }

  // Find the bundledAssets list and add new entry
  // Pattern: 'assets/data/something.json',
  final pattern = RegExp(r"('assets/data/[^']+\.json',)\n  \];");
  final match = pattern.firstMatch(content);

  if (match != null) {
    // Add new entry before the closing ];
    final replacement = "${match.group(1)}\n    '$assetPath',\n  ];";
    content = content.replaceFirst(pattern, replacement);
    await file.writeAsString(content);
    return true;
  }

  // Alternative pattern with different formatting
  final altPattern = RegExp(r"('assets/data/[^']+\.json',\s*)\];");
  final altMatch = altPattern.firstMatch(content);

  if (altMatch != null) {
    final replacement = "${altMatch.group(1)}'$assetPath',\n  ];";
    content = content.replaceFirst(altPattern, replacement);
    await file.writeAsString(content);
    return true;
  }

  print('  WARNING: Could not auto-update DeckService. Please add manually:');
  print("    '$assetPath',");
  return false;
}
