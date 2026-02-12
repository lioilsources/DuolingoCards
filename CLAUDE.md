# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Flutter App

```bash
flutter run                          # Debug mode
flutter run -d chrome                # Web
flutter run -d macos                 # macOS
flutter run -d ios                   # iOS simulator
flutter build apk / ios / web / macos  # Release builds
flutter test                         # All tests
flutter test test/widget_test.dart   # Single test
flutter analyze                      # Lint
flutter pub get                      # Dependencies
```

### Quiz Generator (Go CLI)

```bash
cd quiz-generator
go build ./cmd/generator/                                    # Build
go run cmd/generator/main.go -type capitals -limit 50        # World capitals
go run cmd/generator/main.go -type dogbreeds -limit 50       # Dog breeds
go run cmd/generator/main.go -type catbreeds -limit 50       # Cat breeds
go run cmd/generator/main.go -type geography -category rivers -limit 3  # Geography
go run cmd/generator/main.go -type pokemon -limit 151        # Pokémon Gen 1
```

Output goes to `quiz-generator/output/decks/` (JSON) and `quiz-generator/output/media/` (images).

## Architecture Overview

DuolingoCards is a flashcard app with swipeable cards, priority-based spaced repetition, deck store with in-app purchases, and cloud API integration.

### Screen Flow

```
HomeScreen (entry point)
├── Displays bundled deck + downloaded decks
├── Tap deck → DeckScreen (study mode)
└── Store button → DeckStoreScreen
                   ├── Browse catalog (free + paid)
                   ├── IAP purchase flow
                   └── Download → returns to HomeScreen
```

### Flutter App Structure

```
lib/
├── main.dart                    # App entry, MaterialApp
├── models/
│   ├── catalog.dart             # CatalogItem, Catalog, DeckPreview (API responses)
│   ├── deck.dart                # Deck with mediaBaseUrl
│   └── flashcard.dart           # Flashcard + CardMedia (images, audio)
├── screens/
│   ├── home_screen.dart         # Deck list + store navigation
│   ├── deck_store_screen.dart   # Catalog browser + IAP UI
│   └── deck_screen.dart         # Study/review with swipe gestures
├── services/
│   ├── api_service.dart         # HTTP client (Dio) for remote API
│   ├── local_deck_service.dart  # File-based deck storage in app documents
│   ├── iap_service.dart         # In-app purchase handling (singleton)
│   ├── deck_service.dart        # Bundled asset deck loader
│   ├── priority_service.dart    # Spaced repetition + SharedPreferences
│   ├── audio_service.dart       # AudioPlayer wrapper
│   └── media_download_service.dart  # Downloads and caches deck media locally
└── widgets/
    ├── card_stack.dart          # Swipe gesture detection & animation
    ├── flashcard_widget.dart    # 3D flip animation + media display
    ├── card_widget_factory.dart # Factory pattern for card type widgets
    └── quiz_card_widget.dart    # Quiz-style card rendering
```

### Quiz Generator Structure (Go)

```
quiz-generator/
├── cmd/generator/main.go        # CLI entry + dispatcher (switch on -type flag)
└── internal/
    ├── generator/interface.go   # QuizGenerator interface + QuizItem/Field/Options types
    ├── deck/builder.go          # Deck JSON builder (NewBuilder → AddCard → SaveJSON)
    ├── media/downloader.go      # HTTP file downloader + SVG→PNG conversion
    ├── sparql/                  # Wikidata SPARQL client (used by capitals, breeds)
    ├── capitals/                # World capitals from Wikidata
    ├── dogbreeds/               # Dog breeds from Wikidata
    ├── catbreeds/               # Cat breeds from Wikidata
    ├── geography/               # Mountains/rivers from OpenStreetMap Overpass API
    ├── overpass/                 # Overpass API client
    ├── maps/                    # Map tile renderer for geography cards
    └── pokemon/                 # Pokémon from PokéAPI (pokeapi.co)
```

#### Adding a New Generator

Each generator implements `QuizGenerator` interface from `internal/generator/interface.go`:

```go
type QuizGenerator interface {
    Name() string
    FetchData(opts Options) ([]QuizItem, error)
    DownloadMedia(items []QuizItem, outputDir string) ([]QuizItem, error)
}
```

Steps: create package in `internal/`, implement the interface, add case to switch in `cmd/generator/main.go`.

#### Data Sources by Generator

| Generator | Data Source | Auth |
|-----------|-------------|------|
| capitals, dogbreeds, catbreeds | Wikidata SPARQL | None |
| geography | OpenStreetMap Overpass API | None |
| pokemon | PokéAPI (pokeapi.co) | None |

### Swipe Gestures (DeckScreen)

- **Up**: Mark as known (decrease priority)
- **Down**: Mark as unknown (increase priority)
- **Left**: Next card (algorithm selection)
- **Right**: Previous card (history navigation)
- **Long press**: Flip card

### Card Types

- **Basic**: Traditional flashcard with front/back and 3D flip animation (`FlashcardWidget`)
- **Quiz**: Visual knowledge cards displaying image → title/subtitle/fields (`QuizCardWidget`)

`CardWidgetFactory` selects the appropriate widget based on `card.isQuiz`.

### Key Services

- **ApiService**: HTTP client with endpoints `/api/catalog`, `/api/decks/{id}`, `/api/decks/{id}/preview`
- **LocalDeckService**: Stores decks as `{appDocDir}/decks/{deckId}/deck.json`
- **IAPService**: Singleton, product IDs follow `com.example.duolingocards.deck.{deckId}`
- **PriorityService**: Weighted random selection where priority (1-10) = selection weight

### State Management

- Uses local `setState()` in StatefulWidgets (no Provider/Riverpod)
- `IAPService` is a singleton for global purchase state

### Flashcard Media

Cards support structured media via `CardMedia`:
```dart
media: {
  image: "url",
  audioFront: "url",
  audioBack: "url"
}
```
Legacy fields (`imageUrl`, `frontAudio`, `backAudio`) supported for backwards compatibility.

### Data Persistence

| Data | Storage Location |
|------|------------------|
| Card priorities | `SharedPreferences` key `card_priorities_{deckId}` |
| Downloaded decks | `{appDocDir}/decks/{deckId}/deck.json` |
| Deck media | `{appDocDir}/decks/{deckId}/media/` |
