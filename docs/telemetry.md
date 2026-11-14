# Anonymous usage statistics

Lexify sends a small set of anonymous usage events through
[`ol1n_telemetry`](https://github.com/lioilsources/Ol1nTelemetry) so the owner
can see what new learners do after the first launch, where they stop, how the
deck store and purchases work out, and which features experienced learners
never touch. This file is the **event dictionary**: the constant
`lexifyDictionary` (`lib/telemetry/telemetry_dictionary.dart`) and this
document list exactly the same events and properties, and
`test/telemetry_test.dart` fails when they drift apart.

Adding an event or a property is a change to the privacy policy
(`docs/privacy.html`) and to the store privacy answers. Ask the owner first.

## Where it runs

| Platform | Measured |
|---|---|
| iOS, macOS | yes |
| Windows, Linux | yes |
| **Android** | **never.** Lexify's Google Play target audience includes children under 13, so the Families policy applies. `startTelemetry` returns before `Telemetry.init`, every `Telemetry.*` call is a no-op and the settings entry is hidden. The Android release workflow gets no key either. |
| Web | never (the package has no sink on the web) |

`test/telemetry_test.dart` checks the Android rule.

## Rules

The rules of `ol1n_telemetry` apply unchanged: no persistent identifier
(a random session id lives in memory only), cohorts computed on the device
and sent only as bands, only enums, bands and numbers (no free text: the
store search query, the card report comment and card content never leave
the device), no key → no network, off wipes the queue at once, the app never
waits for measuring and never reads it. Events go only to the developer's own
receiver (StoreMetrics, protocol v1); no third party gets them. The receiver
stores no IP address, only the country. Raw events are kept 12 months.

## Configuration

| `--dart-define` | Meaning |
|---|---|
| `TELEMETRY_KEY` | Lexify's key at the receiver. Empty → nothing is sent. |
| `TELEMETRY_HOST` | Receiver address, `https`. Empty → nothing is sent. |
| `TELEMETRY_DEBUG` | `true` prints events to the console instead of sending them. |
| `TELEMETRY_TESTER` | `true` marks a tester build (`tester: true`). |

`release-ios`, `release-macos`, `release-windows` and `release-linux` pass
the key and host from the GitHub secrets of the same names. `release-android`
does not, on purpose. The values never go into this public repository.

Storage: the client's few `telemetry_*` values live in SharedPreferences
(`PrefsTelemetryStore`). A device that already has Lexify data (seeded free
decks, entitlements or card priorities) reports `days_band: pre`.

## Screens

Every `push` names its route; `TelemetryNavigatorObserver` maps the name.

| Route | Screen |
|---|---|
| `/` | `home` |
| `/store` | `store` |
| `/store/deck` | `store_deck` |
| `/study` | `study` |
| `/settings` | `settings` (only exists where measuring runs) |

## Activation

The **first rated card** on this install: the first swipe left (don't know)
or right (know) in a study session. Study has no end of a set, so the first
rating is the first real use.

## Features

For `feature_use` / `feature_snapshot`:

| Feature | When |
|---|---|
| `search` | the store search was used (never the query) |
| `reorder` | a deck was moved on home |
| `restore` | Restore purchases |
| `pronounce` | a word was spoken aloud |
| `flip` | a card was flipped |
| `card_back` | back to the previous card (swipe down) |
| `card_report` | the report-a-card sheet was opened |
| `style_pick` | another image style picked in the store |
| `lang_pick` | the language pair changed in the store |

## Common properties

Sent with every event.

| Property | Type | Values |
|---|---|---|
| `app_version` | enum | the app version (`kAppVersion`, checked against `pubspec.yaml`) |
| `platform` | enum | `ios`, `macos`, `windows`, `linux`, `other` (`android` never occurs) |
| `lang` | enum | UI language: `en`, `cs`, `ar`, `de`, `el`, `es`, `fr`, `he`, `hi`, `id`, `ja`, `ko`, `pt`, `pt_PT`, `ru`, `tr`, `vi`, `zh`, `zh_Hant` |
| `session_band` | band | session number: `1`, `2`, `3-5`, `6-10`, `11+` |
| `days_band` | band | days since measuring began: `0`, `1`, `2-6`, `7-29`, `30+`, `pre` |
| `first_session` | bool | the very first session of a new install |
| `tester` | bool | tester build or tester device |

## Events

Each event says which question of the plan (`04-PLAN-analytika` §1) it
answers. Value lists: `deck` is `kDeckIds` (the 15 bundled deck slugs plus
`other`), `style` is the style registry in `lib/models/card_style.dart` plus
`other`, `l2` is `kCardLangs` (the card languages of the bundled decks plus
`other`).

### `app_open`

Cold start, or a new session after more than 30 minutes in the background.
*New user funnel; does a learner come back.*

| Property | Type | Values |
|---|---|---|
| `start` | enum | `cold`, `resume` |
| `session_band_first` | bool | the first session of this install in its `session_band` |
| `days_band_first` | bool | the first session of this install in its `days_band` |
| `campaign` | campaign | optional; QR campaign of a new install, `^[a-z0-9-]{1,24}$` (not set by Lexify) |

### `screen_view`

A screen appeared. *What a new learner does after the first launch.*

| Property | Type | Values |
|---|---|---|
| `screen` | enum | `home`, `store`, `store_deck`, `study`, `settings`, `other` |
| `prev` | enum | the previous screen, or `none` |

### `screen_leave`

A screen was left. *How long on which screen; back-and-forth A → B → A.*

| Property | Type | Values |
|---|---|---|
| `screen` | enum | as in `screen_view` |
| `secs` | int | foreground seconds on the screen |
| `actions` | int | app events, feature uses and locked taps during the stay |

### `session_pause`

The app went to the background or is closing. Sent at once. *When and where
learners stop.*

| Property | Type | Values |
|---|---|---|
| `active_secs` | int | foreground seconds in this session |
| `screen` | enum | the screen at the time, or `none` |
| `screen_secs` | int | foreground seconds on that screen |

### `activation`

The first rated card on this install. Once per install. *How many new
learners get to real use, and how fast.*

| Property | Type | Values |
|---|---|---|
| `secs` | int | seconds since this session's `app_open` |

### `feature_use`

The first use of a feature in a session. *What experienced learners use.*

| Property | Type | Values |
|---|---|---|
| `feature` | enum | see Features |

### `feature_snapshot`

After `app_open` of the 3rd, 6th and 11th session: which features this
install has ever used. *What experienced learners never use.*

| Property | Type | Values |
|---|---|---|
| `f_search` | bool | search used |
| `f_reorder` | bool | reorder used |
| `f_restore` | bool | restore used |
| `f_pronounce` | bool | pronunciation used |
| `f_flip` | bool | card flip used |
| `f_card_back` | bool | previous card used |
| `f_card_report` | bool | card report opened |
| `f_style_pick` | bool | style picked |
| `f_lang_pick` | bool | language pair changed |
| `features_used` | int | how many of them |

### `error_shown`

The learner saw an error. *Where learners struggle.*

| Property | Type | Values |
|---|---|---|
| `kind` | enum | `store_load` (store list failed), `download` (deck pictures failed), `purchase_start` (store sheet could not open), `deck_not_owned`, `no_voice` (no OS voice for the language) |
| `screen` | enum | the screen at the time, or `none` |

### `locked_tap`

A paid deck the learner does not own was opened in the store. *Interest in
paid content.*

| Property | Type | Values |
|---|---|---|
| `target` | enum | `paid_deck` |

### `deck_view`

A deck's store page was opened. *Store funnel: which decks are looked at.*

| Property | Type | Values |
|---|---|---|
| `deck` | enum | deck slug |
| `free` | bool | free deck |
| `owned` | bool | already owned (free or bought) |

### `deck_add`

A (deck, language pair, style) was put on home. *Store funnel: from looking
to adding.*

| Property | Type | Values |
|---|---|---|
| `deck` | enum | deck slug |
| `style` | enum | image style |
| `l2` | enum | language being learned |
| `free` | bool | free deck |

### `card_report`

A card report was sent (mail) or copied (no mail app). Only the issue type,
never the comment or the card. *Where content is broken.*

| Property | Type | Values |
|---|---|---|
| `issue` | enum | `translation`, `image`, `pronunciation`, `meaning`, `other` |
| `via` | enum | `mail`, `clipboard` |

### `study_start`

A study session opened. *What learners study, from where.*

| Property | Type | Values |
|---|---|---|
| `deck` | enum | deck slug |
| `style` | enum | image style |
| `l2` | enum | language being learned |
| `free` | bool | free deck |
| `from` | enum | `home`, `store` |

### `study_end`

The study session was left. `ok` with at least one rated card, `cancel`
without any, `background` when the app was left mid-session and not
resumed. *How long and how much learners study; sessions opened and left
without a rating.*

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background` |
| `secs` | int | foreground seconds |
| `rated` | int | cards rated |
| `known` | int | rated as known |
| `unknown` | int | rated as not known |

### `purchase_start`

The learner confirmed buying a deck. *Purchase funnel.*

| Property | Type | Values |
|---|---|---|
| `deck` | enum | deck slug |

### `purchase_end`

The store answered: `ok` bought, `cancel` closed the sheet, `error` failed
or could not start. *Where purchases fail.*

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background` |
| `secs` | int | foreground seconds |

### `download_start`

Deck pictures started downloading (home fetches the free decks on first
launch; the store fetches a newly added deck). *First-launch wait; where
downloads fail.*

| Property | Type | Values |
|---|---|---|
| `deck` | enum | deck slug |
| `style` | enum | image style |
| `from` | enum | `home`, `store` |

### `download_end`

The download ended. `secs` is the load time.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background` |
| `secs` | int | foreground seconds |

## Reading the data

`store-metrics report lexify` on the receiver host. Tester builds are left
out by default.
