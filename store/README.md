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

## All decks bundle (complete-the-set) — manual step, NOT DONE YET

> Status: none of these five products exists in App Store Connect or Play
> Console yet. The app already asks the store for them and simply hides the
> offer while the store returns nothing. Create them by hand; IDs and the
> number of tiers are irreversible once created.

Five non-consumables that unlock the **same** content: every paid deck,
including decks added later. The app offers exactly one, chosen by how many
paid decks the user already owns, and shows that product's store price (plus
tier 0's price struck through on tiers 1-4). Defined in `assets/catalog.json`
under `all_decks`; the choice is `lib/services/set_ladder.dart`.

| Tier | Product ID (App Store = Play) | Price (USD price point) | Offered when owned decks |
|---|---|---|---|
| 0 | `com.ol1n.duolingocards.decks_all` | 4.99 | 0 |
| 1 | `com.ol1n.duolingocards.decks_all_s1` | 3.99 | 1 |
| 2 | `com.ol1n.duolingocards.decks_all_s2` | 2.99 | 2 |
| 3 | `com.ol1n.duolingocards.decks_all_s3` | 1.99 | 3 |
| 4 | `com.ol1n.duolingocards.decks_all_s4` | 0.99 | 4 or more |

- Type: Non-Consumable (App Store) / one-time product (Play), all territories.
  Prices are USD price points; let the store convert other currencies, do not
  hand-tune local prices.
- Same display name (en: `All decks`) and the same paywall review screenshot
  for all five.
- **Do not** enable tiers 1-4 as promoted in-app purchases, or they could be
  bought from the App Store page at the reduced price.

Review notes text (same for all five):

> Complete-the-set pricing: these products unlock identical content. The app
> offers exactly one of them, chosen by how many items the customer already
> owns, so earlier purchases are credited.

## Localizations

At least one localization is required; `iap_products.csv` carries all 17, one row
per (product, locale). Display name is capped at 30 characters and description at
45 — every row is inside both. Locale names are spelled the way App Store Connect
spells them, so they can be matched by eye while clicking through.

## Google Play

The same product ID works on both stores. It is lowercase throughout, which is
what lets one string satisfy Play's stricter rule as well as Apple's — Play
rejects uppercase. Product IDs need not match the app's bundle ID
(`com.ol1n.duolingoCards`; on Android `com.ab.duolingoCards`), which keeps its capital C. Product type on Play is
**one-time product**.

## Regenerating

```
python3 tools/iap_review_shot.py                  # 1242x2208 (default)
python3 tools/iap_review_shot.py --size 640x920   # if ASC rejects the size
```

The product list is derived from `assets/catalog.json` and `assets/decks/*.json`,
so it cannot drift from what the app ships.
