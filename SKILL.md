# SKILL.md — Content & Store Operations

Practical runbook for creating decks, generating content, and managing the store and CDN.

---

## 1. Creating a New Deck

### 1.1 Author `deck.yaml`

```
decks/<slug>/deck.yaml
```

Minimal skeleton:

```yaml
slug: food-vegetables
version: 1
tier: 0          # 0 = free, 1 = 1 credit (see §4)
styles:
  - flux-real
  - pony-cartoon
default_style: flux-real   # always flux-real unless there's a specific reason

cards:
  - key: veg.carrot
    hint: orange root vegetable, sweet, crunchy
    image: veg.carrot.png
    brief:
      subject: carrot
      attrs: [whole, fresh, bright orange, leafy green top]
      setting: [white background, soft studio light]
      avoid: [text, humans, cooked]
```

- `key` — unique within the deck, used as priority ID
- `hint` — human description for translators / LLM context
- `image` — filename in `images/<style>/` (always `.png`)
- `brief` — visual brief expanded to ComfyUI prompts (dual prompting: FLUX + Pony)
- `brief_attrs` — deck-level LoRA/style attrs prepended to every Pony prompt (optional)

### 1.2 Author `i18n/cs.yaml` (CS pivot)

```
decks/<slug>/i18n/cs.yaml
```

```yaml
veg.carrot:
  label: mrkev
  summary: oranžová kořenová zelenina
  info: Bohatá na betakaroten, sladká chuť, pochází ze Střední Asie.
```

Every card key must have `label` (word shown on card), `summary` (short gloss), `info` (back-side info). CS is the **only** language authored by hand — all others are machine-translated.

### 1.3 Lint before generating

```bash
make lint               # checks card keys, missing images refs, orphan i18n keys
make lint-strict        # + enforces all 30 languages + all images present
```

---

## 2. Generating Translations

```bash
make translate DECK=food-vegetables   # translate missing languages (cs → 29 others)
make translate                        # all decks, all missing languages
make translate DECK=food-vegetables WORKERS=10  # more parallel workers (default 5)
```

- Source: CS pivot in `i18n/cs.yaml`
- Output: `i18n/<lang>.yaml` for each of the 30 target languages
- LLM server: `http://192.168.88.66:8080` (OpenAI-compatible)
- Idempotent — only generates missing keys; use `translate-force` to regenerate all

```bash
make translate-force DECK=food-vegetables   # regenerate all languages, even existing
```

---

## 3. Generating Images

Both styles must be generated. `flux-real` is the default shown to users; `pony-cartoon` is the secondary style.

### 3.1 Standard generation

```bash
make images DECK=food-vegetables STYLE=flux-real     # generate flux-real images
make images DECK=food-vegetables STYLE=pony-cartoon  # generate pony-cartoon images
```

- ComfyUI server: `http://192.168.88.66:8188`
- Output: `decks/<slug>/images/<style>/*.png`
- Skips already-generated images; use `images-force` to regenerate

```bash
make images-force DECK=food-vegetables STYLE=flux-real
```

### 3.2 Iterative tuning (optional, for quality)

The `tune` target runs a generate → VL-validate → refine loop (default 4 iterations, target score 8/10):

```bash
make tune DECK=food-vegetables STYLE=flux-real
make tune DECK=food-vegetables STYLE=pony-cartoon
```

- Saves winning image to `images/<style>/*.png` (overwrites)
- Saves winning prompt to `decks/<slug>/tuned/<style>.yaml`
- Saves LLM transcript to `decks/<slug>/tuned/logs/`

### 3.3 Debug: print prompts without generating

```bash
make prompts DECK=food-vegetables STYLE=flux-real
```

### 3.4 Full pipeline in one shot

```bash
make new-deck DECK=food-vegetables STYLE=flux-real
# = translate + images (flux-real only) + build
```

To generate both styles:

```bash
make translate DECK=food-vegetables
make images DECK=food-vegetables STYLE=flux-real
make images DECK=food-vegetables STYLE=pony-cartoon
make build
```

---

## 4. Store Management

The store lists every deck whose `assets/decks/<slug>.json` is registered in `pubspec.yaml`. `LanguageDeckService.availableSlugs()` discovers them via `AssetManifest` at runtime.

### 4.1 Tier

Set in `deck.yaml`:

| Tier | Credits | Meaning |
|------|---------|---------|
| `0`  | 0       | Free — user taps "Přidat zdarma" |
| `1`  | 1       | Paid — user spends 1 credit |

Credit pricing lives in `assets/catalog.json` under `deckPricing`. Do not change tiers of existing live decks.

### 4.2 Build deck.json

```bash
make build    # rebuilds all assets/decks/*.json from decks/*/deck.yaml + i18n/*.yaml
```

### 4.3 Preview images (3 per deck, required)

Every deck in the store must have 3 preview images — the first 3 cards' images in `flux-real` style:

```bash
# Copy first 3 flux-real images to assets/previews/<slug>/flux-real/
SLUG=food-vegetables
mkdir -p assets/previews/$SLUG/flux-real
# Get first 3 card image names from deck.json:
python3 -c "
import json
d = json.load(open('assets/decks/$SLUG.json'))
for c in d['cards'][:3]: print(c['image'])
"
# Then copy those specific files:
cp decks/$SLUG/images/flux-real/<img1>.png assets/previews/$SLUG/flux-real/
cp decks/$SLUG/images/flux-real/<img2>.png assets/previews/$SLUG/flux-real/
cp decks/$SLUG/images/flux-real/<img3>.png assets/previews/$SLUG/flux-real/
```

### 4.4 Register in pubspec.yaml

Add under `flutter: assets:` in `pubspec.yaml`:

```yaml
    # Tier-0 free deck
    - assets/decks/<slug>.json
    - assets/previews/<slug>/flux-real/

    # Tier-1 paid deck (same — full images come from CDN)
    - assets/decks/<slug>.json
    - assets/previews/<slug>/flux-real/
```

**Exception:** A fully bundled pilot deck (like `colors-basic`) also registers full images:

```yaml
    - assets/decks/colors-basic.json
    - assets/previews/colors-basic/flux-real/
    - decks/colors-basic/images/flux-real/
    - decks/colors-basic/images/pony-cartoon/
```

After editing `pubspec.yaml`, run `flutter pub get`.

### 4.5 Home screen — download-before-show

The home screen only shows a deck once its images are accessible (downloaded to docsDir **or** fully bundled). The check is in `_imagesReady()` in `home_screen.dart`. Do not bypass this — the deck will appear without images.

---

## 5. CDN Management

Full images for CDN decks are served from GitHub Pages:

- **URL:** `https://lioilsources.github.io/DuolingoCards`
- **Source:** branch `downable-in-app-decks`, path `/docs`
- **Local path:** `docs/decks/<slug>/`

### 5.1 Add a deck to CDN

```bash
SLUG=food-vegetables
STYLE=flux-real

mkdir -p docs/decks/$SLUG/images/$STYLE
cp assets/decks/$SLUG.json docs/decks/$SLUG/deck.json
cp decks/$SLUG/images/$STYLE/*.png docs/decks/$SLUG/images/$STYLE/
```

Verify structure:
```
docs/decks/<slug>/
  deck.json                  ← built by make build
  images/flux-real/*.png     ← 50 images
```

### 5.2 Current CDN decks

| Deck | Style |
|------|-------|
| animals-insects | flux-real |
| food-fruits | flux-real |

### 5.3 Publish

```bash
git add docs/decks/<slug>/
git commit -m "cdn: add <slug> flux-real images"
git push
```

GitHub Pages redeploys automatically (typically < 2 min). Check status:

```bash
gh api repos/lioilsources/DuolingoCards/pages | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['status'])"
```

### 5.4 Download flow (app side)

`DeckDownloadService.downloadDeck(slug, style)`:
1. Downloads `deck.json` from CDN → saves to `{docsDir}/decks/<slug>/deck.json`
2. Reads card image filenames from downloaded JSON
3. Downloads each `images/<style>/<img>.png` → saves to `{docsDir}/decks/<slug>/images/<style>/`
4. Skips images already on disk (idempotent)

Triggered automatically after a user unlocks/adds a deck (if images not already in docsDir).

---

## 6. Adding a Complete New Deck — Checklist

```
[ ] 1. Create decks/<slug>/deck.yaml  (tier, styles, default_style: flux-real, cards + briefs)
[ ] 2. Create decks/<slug>/i18n/cs.yaml  (label/summary/info for every card)
[ ] 3. make lint DECK=<slug>
[ ] 4. make translate DECK=<slug>
[ ] 5. make images DECK=<slug> STYLE=flux-real
[ ] 6. make images DECK=<slug> STYLE=pony-cartoon
[ ] 7. make build
[ ] 8. Copy 3 preview images → assets/previews/<slug>/flux-real/
[ ] 9. Register deck.json + previews in pubspec.yaml
[10] 10. For CDN decks: copy deck.json + images → docs/decks/<slug>/
[11] 11. git add + commit + push
[12] 12. make lint-strict  (final validation)
```
