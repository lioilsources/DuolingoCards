# App Store Connect — app metadata

Everything App Review asks for, with the character limit each field enforces.
Copy-paste ready; the counts in brackets are what the text below actually uses.

## URLs

| Field | Value |
|---|---|
| Marketing URL | `https://lioilsources.github.io/DuolingoCards/` |
| Support URL | `https://lioilsources.github.io/DuolingoCards/support.html` |
| Privacy Policy URL | `https://lioilsources.github.io/DuolingoCards/privacy.html` |

All three are served by GitHub Pages from `main`/`docs`, so they go live with
the merge — no separate deploy step.

## Identity

| Field | Limit | Value |
|---|---|---|
| App Name | 30 | `Lexify` [6] |
| Subtitle | 30 | `Vocabulary flashcards` [21] |
| Primary category | — | Education |
| Secondary category | — | Reference |
| Copyright | — | `2026 Oldřich Vorechovský` |
| Age rating | — | 4+ (no objectionable content, no user-generated content, no ads) |

## Promotional Text (170)

Editable without a new build — use it for what changed most recently.

```
Ten decks of 50 illustrated cards, in 17 languages. Swipe to sort what you
know from what you don't — the cards you miss come back sooner.
```
[141]

## Keywords (100, comma-separated, no spaces after commas)

```
vocabulary,flashcards,language,learn,memorize,spaced,repetition,words,study,translate,cards,offline
```
[99 — one character to spare]

Slightly roomier variant if you want to swap a term in:

```
vocabulary,flashcard,language,learn,memorize,spaced,repetition,words,study,translate,offline
```
[92]

Do not repeat the app name or the category — Apple already indexes both, and
duplicates waste the budget. Singular forms match plurals, so `flashcard`
covers `flashcards`.

## Description (4000)

```
Lexify teaches vocabulary with picture flashcards you sort by swiping.

Every card pairs a word with an illustration, a short definition, and
pronunciation from your device's own voice. Swipe up when you know a word,
down when you don't — Lexify shows the ones you miss more often and the ones
you know less often, so your time goes where it is needed.

PICK YOUR PAIR
Choose the language you already speak and the one you are learning. All 17
languages are available in every deck: Arabic, Chinese, Czech, English,
French, German, Greek, Hebrew, Hindi, Indonesian, Japanese, Korean,
Portuguese, Russian, Spanish, Turkish, and Vietnamese. Add the same deck twice
in different pairs at no extra cost.

TEN DECKS, FIFTY CARDS EACH
Pets, colours, and numbers are free. Birds, farm animals, insects, reptiles
and amphibians, marine animals, wild animals, parts of the body, emotions,
fruit, vegetables, and weather are one-time purchases — buy a deck once and
it unlocks for every language pair and every image style, forever.

TWO LOOKS PER DECK
Each deck comes with photographs and one illustrated style — brush-and-ink,
soft pastel, or watercolour, depending on the deck. Switch whenever you like.

WORKS OFFLINE
Deck images download once, then everything runs on your device. No account, no
sign-up, no server. Your progress never leaves your phone.

BUILT FOR CHILDREN AND ADULTS
No ads, no tracking, no analytics, no data collection of any kind. Pronounce
any word with a tap. Report a wrong translation or image straight from the
card.
```
[~1450]

## What's New (4000) — for the 2.2.1 submission

```
• Report a problem straight from a card — pick what is wrong and send it in
  two taps.
• Buying or adding a deck now confirms your language pair and image style
  first.
• Deck tiles show how many words you know, are learning, and don't know yet.
• Each deck has its own gentle colour, so you can tell animals from food at a
  glance.
```

## Review Information

| Field | Value |
|---|---|
| Sign-in required | No |
| Demo account | Not applicable — no accounts exist |
| Contact | Oldřich Vorechovský · oldrich.vorechovsky.jr@gmail.com |

Notes for the reviewer:

```
Lexify has no backend, no accounts, and no server. All content ships with the
app or downloads from a public GitHub Pages CDN.

In-app purchases: each paid deck is one non-consumable product that unlocks
that deck for all 17 languages and both of its image styles. Purchases are
verified on device by StoreKit; there is no receipt forwarding. "Restore
Purchases" is in the deck store's top bar.

To try a purchase: open the app, tap "Get More Decks", choose any deck marked
with a price, pick a language pair and style, and confirm. Free decks (Pets,
Basic Colors, Numbers) need no purchase and show the same flow.
```

## App Privacy (the questionnaire)

Answer **"No, we do not collect data from this app"**. Nothing in the app
sends data anywhere: no analytics SDK, no crash reporting, no ad network. The
only network traffic is downloading deck images from GitHub Pages, which is
not tied to a user.

The one thing to declare correctly if asked: in-app purchases are processed by
Apple, and we never see payment data.
