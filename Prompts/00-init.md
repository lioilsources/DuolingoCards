# DuolingoCards - Flutter Flashcard App

## Přehled
Cross-platform mobilní aplikace (iOS + Android) pro učení slovíček pomocí flashcards s prioritním algoritmem.

## Technologie
- **Framework:** Flutter (Dart)
- **Persistence:** SharedPreferences (priority + lastSeen)
- **Audio:** audioplayers package
- **Gesta:** flutter built-in GestureDetector + AnimationController

## Datová struktura

### Flashcard
```dart
class Flashcard {
  final String id;
  final String frontText;      // Japonsky
  final String backText;       // Česky
  final String? reading;       // Furigana/romaji
  final String? frontAudio;    // Cesta k audio
  final String? imageUrl;      // Volitelný obrázek
  int priority;                // 1-10 (výchozí 5)
  DateTime? lastSeen;
}
```

### Deck
```dart
class Deck {
  final String id;
  final String name;
  final String frontLanguage;
  final String backLanguage;
  final List<Flashcard> cards;
}
```

## Algoritmus výběru karty
- Vážený random podle priority (vyšší priorita = vyšší šance)
- Swipe nahoru: priorita -= 1 (min 1)
- Swipe dolů: priorita += 1 (max 10)
- Po každé interakci se aktualizuje lastSeen

## UX / Gesta
- **Swipe nahoru:** "Znám" → snížit prioritu
- **Swipe dolů:** "Neznám" → zvýšit prioritu
- **Swipe vlevo/vpravo:** Zatím nepoužito (rezerva)
- **Double tap:** Otočit kartu (přepnout výchozí jazyk)

## Struktura projektu
```
lib/
├── main.dart
├── models/
│   ├── flashcard.dart
│   └── deck.dart
├── services/
│   ├── deck_service.dart      # Načítání JSON
│   ├── priority_service.dart  # Persistence priority
│   └── audio_service.dart     # Přehrávání zvuků
├── screens/
│   └── deck_screen.dart       # Hlavní obrazovka
├── widgets/
│   ├── card_stack.dart        # Stack karet
│   └── flashcard_widget.dart  # Jednotlivá karta s animacemi
assets/
├── data/
│   └── japanese_basics.json   # 10 testovacích slovíček
└── audio/
    └── *.mp3                  # Audio soubory (později)
```

## Implementační kroky

### 1. Inicializace projektu
- [x] Vytvořit Flutter projekt
- [x] Přidat dependencies (audioplayers, shared_preferences)
- [x] Nastavit assets v pubspec.yaml

### 2. Modely a data
- [x] Implementovat Flashcard a Deck modely
- [x] Vytvořit JSON s 10 testovacími japonskými slovíčky
- [x] Implementovat DeckService pro načítání JSON

### 3. Persistence
- [x] Implementovat PriorityService (SharedPreferences)
- [x] Ukládat/načítat priority a lastSeen pro každou kartu

### 4. UI komponenty
- [x] FlashcardWidget s flip animací (3D transform)
- [x] CardStack s gesture detection
- [x] Swipe animace (nahoru/dolů)

### 5. Hlavní logika
- [x] Algoritmus váženého random výběru
- [x] Propojení gest s prioritou
- [x] Double tap pro přepnutí jazyka

### 6. Audio
- [x] Implementovat AudioService
- [ ] Přehrávání výslovnosti při zobrazení/otočení (audio soubory zatím chybí)

## Verifikace
1. `flutter run` na iOS simulátoru i Android emulátoru
2. Ověřit swipe gesta mění prioritu
3. Ověřit persistence po restartu aplikace
4. Ověřit flip animaci a přehrávání audia

## Spuštění
```bash
flutter run
```
