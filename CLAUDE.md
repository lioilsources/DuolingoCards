# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS simulator
flutter run -d android         # Android emulator

# Build release
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS

# Run tests
flutter test                   # All tests
flutter test test/widget_test.dart  # Single test file

# Lint and analyze
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture Overview

DuolingoCards is a Japanese vocabulary flashcard app with swipeable cards, priority-based spaced repetition, deck store with in-app purchases, and cloud API integration.

### Screen Flow

```
HomeScreen (entry point)
├── Displays bundled deck + downloaded decks
├── Tap deck → DeckScreen (study mode)
└── Store button → DeckStoreScreen
                   ├── Browse catalog (free + paid)
                   ├── Preview deck details
                   ├── IAP purchase flow
                   └── Download → returns to HomeScreen
```

### Layer Structure

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
│   └── audio_service.dart       # AudioPlayer wrapper
└── widgets/
    ├── card_stack.dart          # Swipe gesture detection & animation
    └── flashcard_widget.dart    # 3D flip animation + media display
```

### Swipe Gestures (DeckScreen)

- **Up**: Mark as known (decrease priority)
- **Down**: Mark as unknown (increase priority)
- **Left**: Next card (algorithm selection)
- **Right**: Previous card (history navigation)
- **Long press**: Flip card

History is maintained for left/right navigation through previously viewed cards.

### Data Flow

1. **HomeScreen** loads bundled deck via `DeckService` + downloaded decks via `LocalDeckService`
2. **DeckStoreScreen** fetches catalog from API, handles IAP via `IAPService`
3. **DeckScreen** uses `PriorityService` for weighted random card selection (higher priority = more frequent)
4. Priorities persist to `SharedPreferences`, decks persist to JSON files in app documents

### Key Services

- **ApiService**: HTTP client with endpoints `/api/catalog`, `/api/decks/{id}`, `/api/decks/{id}/preview`
- **LocalDeckService**: Stores decks as `{appDocDir}/decks/{deckId}/deck.json`
- **IAPService**: Singleton, product IDs follow `com.example.duolingocards.deck.{deckId}`
- **PriorityService**: Weighted random selection where priority (1-10) = selection weight

### Key Dependencies

- `dio: ^5.4.0` - HTTP client
- `in_app_purchase: ^3.2.0` - Cross-platform IAP
- `path_provider: ^2.1.0` - File system access
- `cached_network_image: ^3.3.0` - Network image caching
- `audioplayers: ^6.0.0` - Audio playback
- `shared_preferences: ^2.2.0` - Priority persistence

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
