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
New and free: Flags of the World — 50 countries with capitals and populations.
Fifteen decks of 50 picture cards in 17 languages; the words you miss come
back sooner.
```
[166]

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

FOURTEEN DECKS, FIFTY CARDS EACH
Pets, colours, and numbers are free. Birds, farm animals, insects, reptiles
and amphibians, marine animals, wild animals, parts of the body, emotions,
fruit, vegetables, and weather are one-time purchases — buy a deck once and
it unlocks for every language pair and every image style, forever.

TWO LOOKS PER DECK
Each deck comes with photographs and one illustrated style — brush-and-ink,
soft pastel, or watercolour, depending on the deck. Switch whenever you like.

WORKS OFFLINE
Deck images download once, then everything runs on your device. No account, no
sign-up. Which words you know never leaves your phone.

BUILT FOR CHILDREN AND ADULTS
No ads, no account, no third-party analytics. Anonymous usage statistics help
us improve Lexify and switch off in Settings. Pronounce any word with a tap. Report a wrong translation or image straight from the
card.
```
[~1450]

## What's New (4000) — 2.3.2

Everything since 2.2.4, the last version that reached the store.

```
• New free deck: Flags of the World. Fifty countries — learn the flag, the
  country, its capital and how many people live there.
• A new home screen. Each deck now shows the three cards you know least, so
  you can see at a glance what to practise. Tap a deck to start.
• Put your decks in your own order: press and hold one, then drag it.
• The Deck Store shows real cards from every deck, in each of its picture
  styles.
• Friendlier, rounder lettering throughout the app.
• Fixed: the clock and battery icons were hard to see on some screens.
```

### Previous — 2.2.4 (the resubmission after the guideline 4 rejection)

App Review rejected 2.2.2 because buttons and labels appeared in mixed
languages (Czech and English on one screen). The UI is now fully localized.

```
• Every button and label now follows your device language. The app speaks
  English or Czech; any other device language gets English throughout.
• Language names in the deck picker are translated too.
```

### Previous — 2.2.1

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
Lexify has no backend and no accounts. All content ships with the app or
downloads from a public GitHub Pages CDN. The app sends anonymous usage
statistics (no identifiers, no personal data) to the developer's own server;
they can be turned off under Settings (gear icon on the home screen).


In-app purchases: each paid deck is one non-consumable product that unlocks
that deck for all 17 languages and both of its image styles. Purchases are
verified on device by StoreKit; there is no receipt forwarding. "Restore
Purchases" is in the deck store's top bar.

The interface is localized in English and Czech and follows the device
language; every other device language sees English. Card content (the words
being learned) is in the language pair the user picks — that is the product,
not the interface.

To try a purchase: open the app, tap the shopping-cart icon in the top-right
corner to open the Deck Store, choose any deck marked with a price, pick a
language pair and style, and confirm. Free decks (Pets, Basic Colors, Numbers)
need no purchase and show the same flow.
```

## App Privacy (the questionnaire)

Answers for the first build with anonymous usage statistics (iOS and macOS,
`docs/telemetry.md`). **Fill in before that build is submitted, and only
after the new `docs/privacy.html` is live.** They match
`ios/Runner/PrivacyInfo.xcprivacy` and `macos/Runner/PrivacyInfo.xcprivacy`.
Until the statistics key is set in CI, the builds send nothing and the old
answer ("No, we do not collect data") is still accurate.

**Privacy Policy URL:** unchanged (`privacy.html` above).

**Do you or your third-party partners collect data from this app?** **Yes.**

**Data types collected** (tick exactly these):

| Category → type | Linked to the user? | Used for tracking? | Purpose |
|---|---|---|---|
| Usage Data → **Product Interaction** | **No** | **No** | **Analytics** |
| Diagnostics → **Performance Data** | **No** | **No** | **Analytics** |

- *Product Interaction*: launches, screens and seconds on them, deck pages
  opened, decks added, study sessions (deck, style, language, cards rated),
  purchase started / finished / cancelled, card reports (kind only), first
  use of features, errors shown (kind only).
- *Performance Data*: how long deck pictures take to download.
- The receiver keeps the country derived from the IP address (the IP itself is
  not stored). Apple counts a location derived from an IP address as *Coarse
  Location*; Kirian declares it, this template does not. **Owner's call:**
  tick Location → Coarse Location (not linked, no tracking, Analytics) and add
  `NSPrivacyCollectedDataTypeCoarseLocation` to both manifests, or leave it.

Not collected (leave unticked): Contact Info, Health & Fitness, Financial
Info, Precise Location, Sensitive Info, Contacts, User Content, Browsing
History, Search History (the store search query is never sent), Identifiers
(no User ID, no Device ID: the session id is random, lives in memory only and
is never reused), Purchases, Other Usage Data, Crash Data, Other Diagnostic
Data, Other Data.

**Linked to the user: No** for every type. **Tracking: No**: nothing is
combined with other companies' data, there is no advertising, no App Tracking
Transparency prompt (`NSPrivacyTracking` is `false`).

In-app purchases are processed by Apple; we never see payment data.
