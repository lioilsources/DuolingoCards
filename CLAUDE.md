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

DuolingoCards is a Japanese vocabulary flashcard app using swipeable cards with priority-based spaced repetition.

### Layer Structure

```
lib/
├── main.dart              # App entry point, MaterialApp setup
├── models/                # Data models (JSON serializable)
│   ├── deck.dart          # Card deck container
│   └── flashcard.dart     # Card with priority (1-10) and lastSeen
├── screens/               # UI screens (StatefulWidgets)
│   └── deck_screen.dart   # Main review screen, handles swipe logic
├── services/              # Business logic
│   ├── audio_service.dart     # AudioPlayer wrapper
│   ├── deck_service.dart      # Loads decks from JSON assets
│   └── priority_service.dart  # Weighted random selection, SharedPreferences persistence
└── widgets/               # Reusable UI components
    ├── card_stack.dart        # Swipe gesture detection & animation
    └── flashcard_widget.dart  # 3D flip animation
```

### Data Flow

1. `DeckScreen` initializes services and loads deck from `assets/data/japanese_basics.json`
2. `PriorityService` loads/saves card priorities to `SharedPreferences`
3. User swipes trigger priority updates:
   - **Up**: Known (decrease priority)
   - **Down**: Unknown (increase priority)
   - **Left/Right**: Skip
4. `PriorityService.selectNextCard()` uses weighted random selection (higher priority = more likely to appear)

### State Management

- Uses local `setState()` in StatefulWidgets (no Provider/Riverpod)
- Persistence via `SharedPreferences` keyed by deck ID

### Key Dependencies

- `audioplayers: ^6.0.0` - Audio playback for pronunciation
- `shared_preferences: ^2.2.0` - Local persistence

### Asset Data Format

Decks are JSON files in `assets/data/`:
```json
{
  "id": "deck-id",
  "name": "Deck Name",
  "frontLanguage": "ja",
  "backLanguage": "cs",
  "cards": [
    {
      "id": "1",
      "frontText": "こんにちは",
      "reading": "konnichiwa",
      "backText": "Dobrý den",
      "priority": 5
    }
  ]
}
```
