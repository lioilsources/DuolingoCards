# DuolingoCards

A cross-platform flashcard learning app with AI-generated quiz decks. Features swipeable cards with spaced repetition, in-app purchases for premium decks, and a Go-based quiz generator that fetches data from Wikidata, OpenStreetMap, and PokéAPI.

## Platforms

| Platform | Status |
|----------|--------|
| iOS | Supported |
| Android | Supported |
| Web | Supported |
| macOS | Supported |
| Linux | Supported |
| Windows | Supported |

## Features

- Swipeable flashcards (Up/Down = known/unknown, Left/Right = navigate)
- 3D flip cards (Basic) and media quiz cards
- Spaced repetition via PriorityService
- Decks: world capitals, animals, dog/cat breeds, geography, Pokémon
- In-app purchases for premium deck downloads
- Offline support for bundled free decks
- Go CLI quiz generator (Wikidata SPARQL, OpenStreetMap Overpass API, PokéAPI)

## Tech Stack

- Flutter / Dart 3.10.7
- Go (quiz-generator CLI)
- audioplayers, dio, cached_network_image, in_app_purchase

## Build

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# macOS
flutter run -d macos

# Quiz generator
cd quiz-generator
go run . capitals
go run . geography
go run . pokemon
```

## Documentation

- [CHANGELOG.md](CHANGELOG.md) — development history
- [GALLERY.md](GALLERY.md) — screenshots and videos
