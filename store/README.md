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

| Apple product ID | Google product ID | Reference name | English display name |
|---|---|---|---|
| `com.ol1n.duolingoCards.deck.animals_birds` | `deck_animals_birds` | Deck Birds | Birds |
| `com.ol1n.duolingoCards.deck.animals_farm` | `deck_animals_farm` | Deck Livestock Animals | Livestock Animals |
| `com.ol1n.duolingoCards.deck.animals_insects` | `deck_animals_insects` | Deck Insects | Insects |
| `com.ol1n.duolingoCards.deck.animals_reptiles` | `deck_animals_reptiles` | Deck Reptiles and Amphibians | Reptiles and Amphibians |
| `com.ol1n.duolingoCards.deck.animals_sea` | `deck_animals_sea` | Deck Marine Animals | Marine Animals |
| `com.ol1n.duolingoCards.deck.animals_wild` | `deck_animals_wild` | Deck Wild animals | Wild animals |
| `com.ol1n.duolingoCards.deck.body_parts` | `deck_body_parts` | Deck Parts of the Body | Parts of the Body |
| `com.ol1n.duolingoCards.deck.emotions` | `deck_emotions` | Deck Emotions | Emotions |
| `com.ol1n.duolingoCards.deck.food_fruits` | `deck_food_fruits` | Deck Fruit | Fruit |
| `com.ol1n.duolingoCards.deck.food_vegetables` | `deck_food_vegetables` | Deck Vegetables | Vegetables |
| `com.ol1n.duolingoCards.deck.weather` | `deck_weather` | Deck Weather | Weather |

## Localizations

Display name is capped at 30 characters and description at 45; every row in the
CSV is inside both limits. Locale names in the CSV are spelled the way App Store
Connect spells them, so they can be matched by eye when clicking through.

Description text is one sentence per language, e.g. English:
`50 illustrated cards in 17 languages.`

## Google Play

Play rejects uppercase in product IDs, so the bundle-id-style Apple IDs cannot be
reused there. The `google_product_id` column carries the flat lowercase form.
Product type is **one-time product** (non-consumable equivalent).
