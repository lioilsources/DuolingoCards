# Plán: CDN-hosted deck content (škálování na 200+ decků)

## Kontext

App aktuálně bundluje **254 MB** assets (2 692 obrázků) pro 15 decků. Při 200+ deckách by to bylo 3+ GB — zcela nereálné. Řešení: obsah decků (JSON + obrázky) hostovaný na CDN, stahovaný do docsDir po nákupu. V app bundlu zůstanou pouze malé preview thumbnaily (3 ks/deck) pro store view a tier-0 decky zůstanou bundlované.

**Co se nemění:** IAP model (credit packs, EntitlementService), priority/spaced repetition, authoring workflow.

---

## Architektura

### CDN struktura
```
cdn.<host>/decks/<slug>/
  deck.json                          # plný JSON (všechny jazyky)
  images/<style>/<image>.webp        # obrázky karet
```

### App bundle (po změně)
```
assets/
  catalog.json                       # rozšířen o metadata všech decků
  previews/<slug>/<style>_1.webp     # 3 thumbnaily per deck per style
  previews/<slug>/<style>_2.webp
  previews/<slug>/<style>_3.webp
  decks/<slug>.json                  # POUZE tier-0 decky (zůstávají offline)
```

### App documents (staženo po nákupu)
```
{docsDir}/decks/<slug>/
  deck.json
  images/<style>/<image>.webp
```

---

## Implementováno (fáze 1)

### ✅ `lib/config/cdn_config.dart` (nový)
```dart
const String kCdnBaseUrl = 'https://ol1n.github.io/duolingo-cards-content';
```

### ✅ `lib/services/deck_download_service.dart` (nový)
- `downloadDeck(slug, style, {onProgress})` — stahuje `deck.json` + všechny obrázky
- `isDownloaded(slug)` — kontroluje docsDir
- Používá `http` package, ukládá do `{docsDir}/decks/<slug>/`
- Progress = stažené soubory / celkový počet

### ✅ `lib/services/language_deck_service.dart` (update)
- `load(slug)` → docsDir první, pak assets bundle
- `isAvailableLocally(slug)` → true pokud v docsDir NEBO v assets
- `invalidateCache(slug)` → pro reload po stažení

### ✅ `lib/widgets/language_card_widget.dart` (update)
- Optional `docsDir` param
- `_buildCardImage()`: `Image.file` (docsDir) → `Image.asset` (bundle) → `CachedNetworkImage` (CDN fallback)

### ✅ `lib/screens/language_deck_study_screen.dart` (update)
- Resolves docsDir v `_loadPriorities()`
- Předává `docsDir` každému `LanguageCardWidget`

### ✅ `lib/screens/deck_store_detail_screen.dart` (update)
- `_CardPreview`: Image.file → Image.asset → CachedNetworkImage z CDN
- Po nákupu: automaticky spustí download
- Progress bar (`LinearProgressIndicator`) během stahování
- Stavové tlačítko: Přidat zdarma / Odemknout / Stáhnout / Studovat

### ✅ `pubspec.yaml`
- Přidán `http: ^1.2.0`

---

## Zbývá (fáze 2)

### catalog.json — deck metadata pro store browsing
Přidat do každého deck záznamu pro browsing bez načítání plného JSON:
```json
{
  "slug": "animals-sea",
  "titles": { "cs": "Mořská zvířata", "en": "Sea Animals", ... },
  "cardCount": 50,
  "tier": 1,
  "styles": ["pony-cartoon", "flux-real"],
  "previewImages": ["animal.dolphin.png", "animal.shark.png", "animal.whale.png"]
}
```
**Nový model `DeckCatalogEntry`** v `lib/models/store_catalog.dart`.
**`DeckStoreScreen`** upravit aby browsoval z katalogu místo `LanguageDeckService.loadAll()`.

### pubspec.yaml — odebrat bundlované obrázky tier-1 decků
```yaml
# Odebrat tyto řádky pro tier-1 decky:
- decks/animals-sea/images/flux-real/
- decks/animals-sea/images/pony-cartoon/
# ... atd.
```
⚠️ Vyžaduje CDN upload předem + otestování download flow.

### Content pipeline (Go) — nové make targety
```bash
make thumbnails DECK=animals-sea     # 3 preview thumbnaily (resize na 200px) → assets/previews/
make upload DECK=animals-sea         # upload deck.json + images na CDN (git push do content repo)
make upload-all                      # upload všechny decky
```

### assets/previews/ — bundle preview thumbnailů
```yaml
# pubspec.yaml přidat:
- assets/previews/animals-sea/
```

---

## CDN prerekvizity (infrastruktura, mimo Flutter)

1. **GitHub Pages** (start — zdarma, zero ops):
   - Nový repo: `ol1n/duolingo-cards-content`
   - URL: `https://ol1n.github.io/duolingo-cards-content/decks/<slug>/...`
   - Repo size limit: 1 GB soft → při ~75 KB/obrázek zvládne 200+ decků
   - **Migrace na Cloudflare R2** pokud limit nestačí: jen změna `kCdnBaseUrl`
2. **Upload**: `git push` do content repo (obrázky komprimovat na ≤ 100 KB WebP)

---

## Co plán neřeší (future)
- Offline fallback / retry po přerušeném downloadu
- Automatický background download po nákupu
- Mazání stažených decků pro uvolnění místa
- Migrace existujících uživatelů (owned tier-1 bez docsDir → "Stáhnout" button)

---

## Ověření
1. `flutter analyze lib/` — clean (no errors)
2. Store view zobrazuje deck tiles (browsing funguje)
3. Nákup tier-1 deck → download progress → "Studovat" button
4. Study screen: obrázky z docsDir (po stažení), nebo z assets (bundlované)
5. Tier-0 bundlované decky fungují offline beze změny
6. App binary menší po odebrání tier-1 obrázků z pubspec.yaml
