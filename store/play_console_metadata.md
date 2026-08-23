# Google Play Console — listing and products

What Play asks for, with its own limits. Play differs from the App Store in
three ways worth knowing before you start:

- **No keywords field.** Play indexes the app name, short description and full
  description instead, so the terms have to appear in the prose.
- **A feature graphic is mandatory.** The listing cannot be submitted without
  one; `store/play_graphics/feature-1024x500.png`.
- **Screenshots are capped at a 2:1 aspect.** The raw captures are 2.165:1 and
  would be rejected, so the Play sets are framed to 9:16 rather than cropped.

## Store listing

| Field | Limit | Value |
|---|---|---|
| App name | 30 | `Lexify — Vocabulary Cards` [25] |
| Short description | 80 | see below |
| Full description | 4000 | see below |
| Category | — | Education |
| Tags | — | Flashcards, Language learning, Vocabulary |
| Contact email | — | `oldrich.vorechovsky.jr@gmail.com` |
| Website | — | `https://lioilsources.github.io/DuolingoCards/` |
| Privacy Policy | — | `https://lioilsources.github.io/DuolingoCards/privacy.html` |

The app name carries "Vocabulary Cards" because Play has no keyword field —
the name is prime indexed text and "Lexify" alone means nothing to search.

### Short description (80)

English [66]:

```
Picture flashcards in 17 languages. Swipe to learn, works offline.
```

Czech [64]:

```
Obrázkové kartičky v 17 jazycích. Učení swipem, funguje offline.
```

### Full description (4000)

```
Lexify teaches vocabulary with picture flashcards you sort by swiping.

Every flashcard pairs a word with an illustration, a short definition, and
pronunciation from your device's own voice. Swipe up when you know a word,
down when you don't — spaced repetition brings back the words you miss more
often and the ones you know less often, so your study time goes where it is
actually needed.

PICK YOUR LANGUAGE PAIR
Choose the language you already speak and the one you are learning. All 17
languages work in every deck: Arabic, Chinese, Czech, English, French, German,
Greek, Hebrew, Hindi, Indonesian, Japanese, Korean, Portuguese, Russian,
Spanish, Turkish and Vietnamese. Add the same deck twice in different pairs at
no extra cost.

FOURTEEN VOCABULARY DECKS, FIFTY CARDS EACH
Pets, basic colours and numbers are free. Birds, farm animals, insects,
reptiles and amphibians, marine animals, wild animals, parts of the body,
emotions, fruit, vegetables and weather are one-time purchases — buy a deck
once and it unlocks for every language pair and every image style, forever.
No subscription.

TWO IMAGE STYLES PER DECK
Each deck comes with photographs and one illustrated style — brush-and-ink,
soft pastel or watercolour, depending on the deck. Switch whenever you like.

LEARN OFFLINE
Deck images download once, then everything runs on your device. No account, no
sign-up, no server. Your learning progress never leaves your phone.

SAFE FOR CHILDREN
No ads, no tracking, no analytics, no data collection of any kind. Pronounce
any word with a tap. Report a wrong translation or image straight from the
card.
```

Czech listings can be added later; the short description above is ready, and
the full description translates one-to-one.

## In-app products

Two files, because 17 locales is 187 rows to type by hand and most of them
buy very little:

| file | rows | when |
|---|---|---|
| `play_products_minimal.csv` | 22 | what to actually enter — en-US + cs-CZ |
| `play_products.csv` | 187 | the full 17 locales, if it is ever automated |

**English alone is safe.** Play falls back to the default language for any
locale you have not translated, so nothing breaks and no policy is violated.
The product name and description only surface in Google's purchase sheet — the
deck names *inside* the app are localized regardless, because those come from
`deck.json`, not from Play. So the cost of English-only is one dialog reading
"Marine Animals" while the app around it says "Mořská zvířata".

Add cs-CZ if the launch audience is Czech; that is the one place the mismatch
would be noticed. The rest can be filled in later — adding a localization is
never destructive.

Every row is inside Play's limits (name 55, description 200), checked rather
than eyeballed.

| Field | Value |
|---|---|
| Product type | **One-time product** (Play's non-consumable) |
| Product IDs | identical to the App Store — see below |
| Price | your choice, per product |

The IDs are shared with iOS deliberately: they are lowercase throughout, which
is what lets one string satisfy Play's rule (no uppercase) and Apple's at the
same time. `assets/catalog.json` is the source of truth — a mismatch does not
fail loudly, the product simply never resolves and the buy button shows no
price.

```
com.ol1n.duolingocards.deck.animals_birds
com.ol1n.duolingocards.deck.animals_farm
com.ol1n.duolingocards.deck.animals_insects
com.ol1n.duolingocards.deck.animals_reptiles
com.ol1n.duolingocards.deck.animals_sea
com.ol1n.duolingocards.deck.animals_wild
com.ol1n.duolingocards.deck.body_parts
com.ol1n.duolingocards.deck.emotions
com.ol1n.duolingocards.deck.food_fruits
com.ol1n.duolingocards.deck.food_vegetables
com.ol1n.duolingocards.deck.weather
```

Free decks — nothing to create: `numbers-1-10`, `colors-basic`,
`animals-pets`.

## Graphics

| Asset | Requirement | File |
|---|---|---|
| App icon | 512×512, PNG, **no alpha** | `store/play_graphics/icon-512.png` |
| Feature graphic | 1024×500, PNG/JPEG | `store/play_graphics/feature-1024x500.png` |
| Phone screenshots | 2–8, max 2:1 aspect | `store/appstore_screenshots/play-phone/` (1080×1920) |
| Tablet screenshots | optional, 7" and 10" | `store/appstore_screenshots/play-tablet/` (1920×1200) |

Regenerate with `python3 tools/play_graphics.py` and
`python3 tools/appstore_shots.py`.

## Data safety

Declare **no data collected and no data shared**. There is no analytics SDK,
no crash reporting and no ad network in the build; the only network traffic is
downloading deck images from GitHub Pages, which is not tied to a user.

Answer the follow-ups: no data collected → the questionnaire ends. Purchases
are processed by Google and we never receive payment data.

## Content rating (IARC questionnaire)

Category **Education / Reference**. Everything else is No: no violence, no
sexual content, no profanity, no gambling, no user-generated content, no user
communication, no location sharing, no personal information collected. Expect
a PEGI 3 / ESRB Everyone rating.

## Target audience

Age groups: all, including under 13. Because children are in the audience,
Play applies its Families policy — which the app already satisfies: no ads, no
analytics, no data collection, no external links inside the app apart from the
report-a-card e-mail.

## Uploading a build to internal testing

Play Console → pick **Lexify** → left nav **Test and release** → **Testing** →
**Internal testing** → **Create new release** (top right) → drop the `.aab` in
→ fill Release notes → **Next** → **Save and publish**.

There is no "replace the existing build" action. A track always takes a *new*
release; the previous one is superseded automatically, which is what updating
an internal test means here.

**versionCode is the thing that will bite.** Play refuses any upload whose
versionCode is not strictly higher than what the track already has, and the
number comes from the CI run counter, not from the app version:

| | versionName | versionCode |
|---|---|---|
| v2.2.2 Android | 2.2.2 | **26** |
| v2.2.2 iOS | 2.2.2 | 28 |

The two differ because `github.run_number` counts per workflow. So if the init
build already sitting in internal testing has a versionCode of 26 or higher,
this AAB is rejected and the fix is to cut a new tag — the counter only moves
forward on a new run. Check the current number under **Test and release → App
bundle explorer**.

## Also required before release

- Signed AAB. The release workflow already builds one and attaches it to each
  GitHub Release as `app-release.aab`, so the first upload can be done by hand:
  grab it from the v2.2.2 release page. Nothing pushes it to a Play track
  automatically — Firebase App Distribution gets the APK instead — so either
  upload manually each time or add a Play publisher step to the workflow.
  Check the signing key first: Play ties the app to whatever key the first
  upload used, and it must match `android/key.properties`.
- Declare the app contains ads: **No**.
- Government app: **No**.
- News app: **No**.
