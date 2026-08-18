import 'package:flutter/material.dart';

/// Pastel color identity for a deck, derived from its slug.
///
/// The point is instant recognition of *what kind* of deck is on screen —
/// animals read rose, food reads blue — so the hue is per category, not per
/// deck: seven animal decks sharing one hue is the feature, their titles tell
/// them apart. New categories fall back to a neutral grey rather than
/// throwing, so a deck added to the content pipeline renders sanely in an app
/// build that predates it.
@immutable
class DeckPalette {
  /// Tile / screen wash — light enough that black text stays readable.
  final Color background;

  /// Slightly stronger companion for borders and small accents.
  final Color accent;

  const DeckPalette({required this.background, required this.accent});

  static const DeckPalette _neutral = DeckPalette(
    background: Color(0xFFF4F4F6),
    accent: Color(0xFFB9BCC6),
  );

  /// Category hues, matched by slug prefix (longest match wins). The two the
  /// user named are literal — animals red, plants blue — the rest are spread
  /// around the wheel so no two adjacent store rows blur together.
  static const Map<String, DeckPalette> _byPrefix = {
    'animals': DeckPalette(
      background: Color(0xFFFBEAEA), // pastel rose
      accent: Color(0xFFE4A3A3),
    ),
    'food': DeckPalette(
      background: Color(0xFFE8EFFA), // pastel blue
      accent: Color(0xFF9FB8DE),
    ),
    'body': DeckPalette(
      background: Color(0xFFFCEFE4), // pastel peach
      accent: Color(0xFFE7BC94),
    ),
    'emotions': DeckPalette(
      background: Color(0xFFFBF4DC), // pastel yellow
      accent: Color(0xFFE2CE85),
    ),
    'colors': DeckPalette(
      background: Color(0xFFF1EAF8), // pastel lavender
      accent: Color(0xFFC3ABDF),
    ),
    'numbers': DeckPalette(
      background: Color(0xFFE6F4EC), // pastel mint
      accent: Color(0xFF97CDAF),
    ),
    'weather': DeckPalette(
      background: Color(0xFFE4F2F5), // pastel cyan
      accent: Color(0xFF92C4CF),
    ),
  };

  /// Palette for [slug]; neutral grey when the category is unknown.
  static DeckPalette of(String slug) {
    for (final entry in _byPrefix.entries) {
      if (slug == entry.key || slug.startsWith('${entry.key}-')) {
        return entry.value;
      }
    }
    return _neutral;
  }
}
