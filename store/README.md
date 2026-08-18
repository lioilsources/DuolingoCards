# In-app purchases

Every paid deck is one **non-consumable** product that unlocks the deck for all
17 languages and both of its image styles. There are no credit packs and no
per-style products.

Free decks — nothing to create in App Store Connect: `numbers-1-10`,
`colors-basic`, `animals-pets`.

The product IDs below must match `assets/catalog.json` character for character.
A mismatch does not fail loudly: `queryProductDetails` just returns the id under
`notFoundIDs`, the store shows no price, and the buy button cannot complete.

## Same for every product

| Field | Value |
|---|---|
| Type | Non-Consumable |
| Availability | All territories |
| Price | your choice — not stored in this repo; the app reads it from the store |
| Tax Category | App Store Software (default) |
| Description (en) | `50 illustrated cards in 17 languages.` |
| Review notes | see below |

Review notes text (same for all 11):

> This unlocks one flashcard deck: 50 cards with images, available in 17
> languages. The deck is visible in the app's Deck Store before purchase, with
> the first three cards shown as a preview. No account or server is involved —
> the purchase is verified on device and unlocks content already in the app or
> downloaded from our CDN.

## Per product

Screenshots are in `store/review_screenshots/`. They are review-only — Apple
never shows them on the store — and each is 1242x2208, a canonical App Store screenshot size.

| Product ID | Reference Name | Display Name (en) | Screenshot |
|---|---|---|---|
| `com.ol1n.duolingocards.deck.animals_birds` | Deck Birds | Birds | `animals-birds.png` |
| `com.ol1n.duolingocards.deck.animals_farm` | Deck Livestock Animals | Livestock Animals | `animals-farm.png` |
| `com.ol1n.duolingocards.deck.animals_insects` | Deck Insects | Insects | `animals-insects.png` |
| `com.ol1n.duolingocards.deck.animals_reptiles` | Deck Reptiles and Amphibians | Reptiles and Amphibians | `animals-reptiles.png` |
| `com.ol1n.duolingocards.deck.animals_sea` | Deck Marine Animals | Marine Animals | `animals-sea.png` |
| `com.ol1n.duolingocards.deck.animals_wild` | Deck Wild animals | Wild animals | `animals-wild.png` |
| `com.ol1n.duolingocards.deck.body_parts` | Deck Parts of the Body | Parts of the Body | `body-parts.png` |
| `com.ol1n.duolingocards.deck.emotions` | Deck Emotions | Emotions | `emotions.png` |
| `com.ol1n.duolingocards.deck.food_fruits` | Deck Fruit | Fruit | `food-fruits.png` |
| `com.ol1n.duolingocards.deck.food_vegetables` | Deck Vegetables | Vegetables | `food-vegetables.png` |
| `com.ol1n.duolingocards.deck.weather` | Deck Weather | Weather | `weather.png` |

## Localizations

At least one localization is required; `iap_products.csv` carries all 17, one row
per (product, locale). Display name is capped at 30 characters and description at
45 — every row is inside both. Locale names are spelled the way App Store Connect
spells them, so they can be matched by eye while clicking through.

## Google Play

The same product ID works on both stores. It is lowercase throughout, which is
what lets one string satisfy Play's stricter rule as well as Apple's — Play
rejects uppercase. Product IDs need not match the app's bundle ID
(`com.ol1n.duolingoCards`), which keeps its capital C. Product type on Play is
**one-time product**.

## Regenerating

```
python3 tools/iap_review_shot.py                  # 1242x2208 (default)
python3 tools/iap_review_shot.py --size 640x920   # if ASC rejects the size
```

The product list is derived from `assets/catalog.json` and `assets/decks/*.json`,
so it cannot drift from what the app ships.
