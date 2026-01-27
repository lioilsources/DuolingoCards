# UX Improvements - Prompty a plány

## 1. Oprava filmového pásu - statické perforace

### Problém

Parallax efekt vytváří prázdná místa při pohybu karty:
- Při swipe nahoru vzniká mezera dole
- Při swipe dolů vzniká mezera nahoře

### Řešení

Odstranit parallax a nechat perforace **statické**. Karty se budou posouvat za pevným filmovým rámem.

```
┌────────────────────────────┐
│□         ↑ karta          □│  ← perforace fixní
│□       pohybuje se        □│
│□           ↓              □│
└────────────────────────────┘
```

### Kritický soubor

- `lib/widgets/card_stack.dart` - metoda `_buildFilmStripOverlay`

### Změna

#### Před (s parallaxem)
```dart
Widget _buildFilmStripOverlay(double height) {
  final parallaxOffset = _verticalOffset * 0.3;
  final extendedHeight = height + 100;

  return Positioned(
    top: 0,
    ...
    child: Transform.translate(
      offset: Offset(0, parallaxOffset),  // ← problém
      child: Row(...)
    ),
  );
}
```

#### Po (statické)
```dart
Widget _buildFilmStripOverlay(double height) {
  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    height: height,
    child: IgnorePointer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPerforations(height),
          _buildPerforations(height),
        ],
      ),
    ),
  );
}
```

### Provedené změny
1. Odstranit `parallaxOffset` proměnnou
2. Odstranit `extendedHeight` (není potřeba)
3. Odstranit `ClipRect` wrapper (zbytečný bez pohybu)
4. Odstranit `Transform.translate` (perforace zůstanou na místě)
5. Vrátit `height` místo `extendedHeight` v `_buildPerforations`

---

## 2. Roztažení karty na celou obrazovku

### Prompt
> roztahni prosim kartu na velikost obrazovky, ted je na portrait prilis kratka

### Problém
Karta používala fixní procento výšky obrazovky (`screenHeight * 0.55`), což v portrait módu vypadalo příliš krátce.

### Řešení
Použít `LayoutBuilder` místo fixního procenta, aby se karta automaticky roztáhla na celou dostupnou výšku.

### Změny v `lib/widgets/card_stack.dart`

#### Před
```dart
double _getCardHeight(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  return screenHeight * 0.55;
}

@override
Widget build(BuildContext context) {
  final cardHeight = _getCardHeight(context);
  return GestureDetector(...);
}
```

#### Po
```dart
double? _availableHeight;

@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = constraints.maxHeight;
      _availableHeight = cardHeight;

      return GestureDetector(...);
    },
  );
}
```

### Změny v `lib/screens/deck_screen.dart`

Přidání `SafeArea` pro správné respektování systémových okrajů:

```dart
body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: CardStack(...),
  ),
),
```

---

## Verifikace

1. `flutter run -d macos`
2. Otestovat swipe nahoru/dolů - perforace musí zůstat na místě
3. Karta vyplňuje celý dostupný prostor
4. Žádné mezery na okrajích při pohybu karet
