// Flashcard data verification script
// Run: dart run tools/verify_flashcards.dart
//
// Verifies:
// 1. Image filename contains normalized backText (Czech translation)
// 2. Audio filename contains reading (Japanese pronunciation)
// 3. Media files exist in assets/media/

import 'dart:convert';
import 'dart:io';

/// Normalize Czech text: lowercase + remove diacritics + replace spaces with hyphens
String normalize(String text) {
  return text
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ů', 'u')
      .replaceAll('ý', 'y')
      .replaceAll('č', 'c')
      .replaceAll('ď', 'd')
      .replaceAll('ě', 'e')
      .replaceAll('ň', 'n')
      .replaceAll('ř', 'r')
      .replaceAll('š', 's')
      .replaceAll('ť', 't')
      .replaceAll('ž', 'z')
      .replaceAll(' ', '-');
}

class VerificationIssue {
  final String deckId;
  final String cardId;
  final String issueType;
  final String message;

  VerificationIssue({
    required this.deckId,
    required this.cardId,
    required this.issueType,
    required this.message,
  });

  @override
  String toString() =>
      '[$deckId] Card $cardId - $issueType: $message';
}

Future<List<VerificationIssue>> verifyDeck(String jsonPath) async {
  final issues = <VerificationIssue>[];

  final file = File(jsonPath);
  if (!await file.exists()) {
    print('ERROR: File not found: $jsonPath');
    return issues;
  }

  final content = await file.readAsString();
  final data = jsonDecode(content) as Map<String, dynamic>;

  final deckId = data['id'] as String;
  final mediaBaseUrl = data['mediaBaseUrl'] as String;
  final cards = data['cards'] as List<dynamic>;

  print('\nVerifying deck: $deckId (${cards.length} cards)');
  print('Media base: $mediaBaseUrl');
  print('-' * 50);

  for (final card in cards) {
    final cardId = card['id'] as String;
    final backText = card['backText'] as String;
    final reading = card['reading'] as String;
    final media = card['media'] as Map<String, dynamic>?;

    if (media == null) {
      issues.add(VerificationIssue(
        deckId: deckId,
        cardId: cardId,
        issueType: 'MISSING_MEDIA',
        message: 'No media object defined',
      ));
      continue;
    }

    final imagePath = media['image'] as String?;
    final audioPath = media['audioFront'] as String?;

    // 1. Verify image filename contains normalized backText
    if (imagePath != null) {
      final normalizedBack = normalize(backText);
      final imageFilename = imagePath.toLowerCase();

      if (!imageFilename.contains(normalizedBack)) {
        issues.add(VerificationIssue(
          deckId: deckId,
          cardId: cardId,
          issueType: 'IMAGE_MISMATCH',
          message: 'Image "$imagePath" does not contain normalized backText "$normalizedBack" (from "$backText")',
        ));
      }

      // Check file exists
      final fullImagePath = '$mediaBaseUrl/$imagePath';
      if (!await File(fullImagePath).exists()) {
        issues.add(VerificationIssue(
          deckId: deckId,
          cardId: cardId,
          issueType: 'IMAGE_NOT_FOUND',
          message: 'Image file not found: $fullImagePath',
        ));
      }
    } else {
      issues.add(VerificationIssue(
        deckId: deckId,
        cardId: cardId,
        issueType: 'MISSING_IMAGE',
        message: 'No image defined for card with backText "$backText"',
      ));
    }

    // 2. Verify audio filename contains reading
    if (audioPath != null) {
      final audioFilename = audioPath.toLowerCase();
      final readingLower = reading.toLowerCase();
      // Also check with spaces replaced by hyphens (e.g., "sea bream" -> "sea-bream")
      final readingHyphenated = readingLower.replaceAll(' ', '-');

      if (!audioFilename.contains(readingLower) && !audioFilename.contains(readingHyphenated)) {
        issues.add(VerificationIssue(
          deckId: deckId,
          cardId: cardId,
          issueType: 'AUDIO_MISMATCH',
          message: 'Audio "$audioPath" does not contain reading "$reading"',
        ));
      }

      // Check file exists
      final fullAudioPath = '$mediaBaseUrl/$audioPath';
      if (!await File(fullAudioPath).exists()) {
        issues.add(VerificationIssue(
          deckId: deckId,
          cardId: cardId,
          issueType: 'AUDIO_NOT_FOUND',
          message: 'Audio file not found: $fullAudioPath',
        ));
      }
    } else {
      issues.add(VerificationIssue(
        deckId: deckId,
        cardId: cardId,
        issueType: 'MISSING_AUDIO',
        message: 'No audioFront defined for card with reading "$reading"',
      ));
    }
  }

  return issues;
}

void main() async {
  print('=== Flashcard Data Verification ===\n');

  final deckFiles = [
    'assets/data/japanese_basics.json',
    'assets/data/japanese-50-animals.json',
    'assets/data/english-50-animals.json',
  ];

  final allIssues = <VerificationIssue>[];

  for (final deckFile in deckFiles) {
    final issues = await verifyDeck(deckFile);
    allIssues.addAll(issues);
  }

  print('\n' + '=' * 50);
  print('VERIFICATION SUMMARY');
  print('=' * 50);

  if (allIssues.isEmpty) {
    print('\n  All OK! No issues found.');
  } else {
    print('\n  Found ${allIssues.length} issue(s):\n');

    // Group by issue type
    final byType = <String, List<VerificationIssue>>{};
    for (final issue in allIssues) {
      byType.putIfAbsent(issue.issueType, () => []).add(issue);
    }

    for (final type in byType.keys.toList()..sort()) {
      print('  $type (${byType[type]!.length}):');
      for (final issue in byType[type]!) {
        print('    - ${issue.toString()}');
      }
      print('');
    }
  }

  // Exit with error code if issues found
  exit(allIssues.isEmpty ? 0 : 1);
}
