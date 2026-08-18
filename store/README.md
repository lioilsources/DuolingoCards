# In-app purchases

Every paid deck is one **non-consumable** product that unlocks the deck for all
17 languages and both of its image styles. There are no credit packs and no
per-style products.

Free decks — nothing to create in App Store Connect: `numbers-1-10`,
`colors-basic`, `animals-pets`.

## Files

| file | what it is |
|---|---|
| `iap_products.csv` | 11 products x 17 locales, one row per localization |
| `review_screenshots/<slug>.png` | the required review screenshot, 1242x1656 |

Regenerate the screenshots with `python3 tools/iap_review_shot.py`.
The product list is generated from `assets/catalog.json` + `assets/decks/*.json`,
so it stays in step with what the app actually ships.

## Per product

Type: **Non-Consumable**. Availability: all territories. Pick your own price tier.
Each one needs its review screenshot uploaded (App Review only — never shown on
the store) and at least one localization; the CSV carries all 17.

| Product ID (both stores) | Reference name | English display name |
|---|---|---|
| `com.ol1n.duolingocards.deck.animals_birds` | Deck Birds | Birds |
| `com.ol1n.duolingocards.deck.animals_farm` | Deck Livestock Animals | Livestock Animals |
| `com.ol1n.duolingocards.deck.animals_insects` | Deck Insects | Insects |
| `com.ol1n.duolingocards.deck.animals_reptiles` | Deck Reptiles and Amphibians | Reptiles and Amphibians |
| `com.ol1n.duolingocards.deck.animals_sea` | Deck Marine Animals | Marine Animals |
| `com.ol1n.duolingocards.deck.animals_wild` | Deck Wild animals | Wild animals |
| `com.ol1n.duolingocards.deck.body_parts` | Deck Parts of the Body | Parts of the Body |
| `com.ol1n.duolingocards.deck.emotions` | Deck Emotions | Emotions |
| `com.ol1n.duolingocards.deck.food_fruits` | Deck Fruit | Fruit |
| `com.ol1n.duolingocards.deck.food_vegetables` | Deck Vegetables | Vegetables |
| `com.ol1n.duolingocards.deck.weather` | Deck Weather | Weather |

## Localizations

Display name is capped at 30 characters and description at 45; every row in the
CSV is inside both limits. Locale names in the CSV are spelled the way App Store
Connect spells them, so they can be matched by eye when clicking through.

Description text is one sentence per language, e.g. English:
`50 illustrated cards in 17 languages.`

## Google Play

The same product ID works on both stores. It is lowercase throughout, which is
what lets it satisfy Play's stricter rule as well as Apple's — Play rejects
uppercase, so a camelCase, bundle-id-shaped ID could not be shared. Product IDs
need not match the app's bundle ID (`com.ol1n.duolingoCards`), which still has
its capital C. Product type on Play is **one-time product**.