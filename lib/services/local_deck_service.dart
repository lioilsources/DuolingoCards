import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';

class LocalDeckService {
  static const String _decksFolder = 'decks';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final decksDir = Directory('${directory.path}/$_decksFolder');
    if (!await decksDir.exists()) {
      await decksDir.create(recursive: true);
    }
    return decksDir.path;
  }

  Future<List<String>> getDownloadedDeckIds() async {
    final path = await _localPath;
    final dir = Directory(path);
    final entries = await dir.list().toList();

    return entries
        .whereType<Directory>()
        .map((e) => e.path.split('/').last)
        .toList();
  }

  Future<bool> isDeckDownloaded(String deckId) async {
    final path = await _localPath;
    final deckFile = File('$path/$deckId/deck.json');
    return deckFile.exists();
  }

  Future<Deck?> loadDeck(String deckId) async {
    final path = await _localPath;
    final deckFile = File('$path/$deckId/deck.json');

    if (!await deckFile.exists()) {
      return null;
    }

    try {
      final jsonString = await deckFile.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Deck.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDeck(Deck deck) async {
    final path = await _localPath;
    final deckDir = Directory('$path/${deck.id}');
    if (!await deckDir.exists()) {
      await deckDir.create(recursive: true);
    }

    final deckFile = File('${deckDir.path}/deck.json');
    final jsonString = json.encode(deck.toJson());
    await deckFile.writeAsString(jsonString);
  }

  Future<void> deleteDeck(String deckId) async {
    final path = await _localPath;
    final deckDir = Directory('$path/$deckId');
    if (await deckDir.exists()) {
      await deckDir.delete(recursive: true);
    }
  }

  Future<List<Deck>> loadAllDecks() async {
    final deckIds = await getDownloadedDeckIds();
    final decks = <Deck>[];

    for (final id in deckIds) {
      final deck = await loadDeck(id);
      if (deck != null) {
        decks.add(deck);
      }
    }

    return decks;
  }
}
