# DuolingoCards (Lexify)

<!-- Max 80 řádků. Co se nevejde, jde do docs/ a sem jeden odkaz. Veřejné repo: žádné LAN IP, domovské cesty, ID. -->

## Účel
Flashcard appka (Flutter) se swipe kartami, prioritním opakováním a obchodem s balíčky
bez backendu: obsah je v binárce a na GitHub Pages CDN, IAP se ověřuje na zařízení.
Obsah staví build-time Go nástroj `content` v `quiz-generator/` přes LLM a ComfyUI na SPARKu.

## Build a test
```bash
flutter pub get                      # deps, regeneruje i lib/l10n
flutter analyze && flutter test      # gate
flutter gen-l10n                     # lib/l10n/app_*.arb → app_localizations*.dart
make screenshots                     # každá obrazovka v každém UI jazyce (booted iOS simulátor) → build/screenshots/
make site-screenshots                # šest shotů pro olin.now → ../ol1n.now/apps/lexify/screenshots/raw/mobile/ios/
make site-screenshots-macos          # totéž na Mac buildu → build/site_screenshots_macos/

make build-tool                      # quiz-generator/bin/content (git-ignored)
make lint | lint-strict              # validace balíčků
make build                           # deck.yaml + i18n/*.yaml → assets/decks/*.json
make translate [DECK=…]              # LLM překlad chybějících jazyků
make images DECK=… STYLE=photo       # text2img přes ComfyUI
make restyle DECK=… STYLE=<style>    # img2img restyle z photo base; `make styles` vypíše styly
make ship DECK=…                     # publish obrázků → build → publish json
```
SPARK adresy: `SPARK_LLM` / `SPARK_IMG` v Makefile, přepsatelné z prostředí (`.env.example`).

## Mapa
- `lib/` — appka: `screens/`, `services/` (entitlementy, IAP, TTS, remote catalog), `models/`, `l10n/`, `theme/`.
- `decks/<slug>/` — autorský obsah: `deck.yaml`, `i18n/<lang>.yaml`, `images/<style>/` (ignorováno), `tuned/`.
- `assets/decks/`, `assets/previews/`, `assets/catalog.json` — bundlovaný obsah.
- `docs/` — GitHub Pages: CDN balíčků (`docs/decks/`), `catalog.json`, privacy/support stránky.
- `quiz-generator/` — Go: `cmd/content` (pipeline), `cmd/generator` (legacy quiz generátory).
- `tools/gen_flags_deck.py` — generuje balíček `geo-flags`; edituj skript, ne výstup.
- `store/` — metadata a assety pro App Store / Play.
- `Prompts/` — plány; `SKILL.md` — postup na tvorbu balíčku.

## Invarianty
- Každý obrázek jde přes ComfyUI (`comfyuiimage.Client`); LLM server obrázky negeneruje.
- `make ship` má pořadí publish-images → build → publish-json; `build` čte publikované stromy
  a rozhoduje o dostupnosti stylu. Nový `assets/previews/<slug>/<style>/` potřebuje vlastní
  řádek pod `flutter.assets` v `pubspec.yaml`.
- Deklarovaný styl není dodaný styl: `deck.json` `styles` se odvozují z obrázků na disku.
- Obsah se píše v pivotu `en` (`langs.Pivot`), shipují jen `Gold` jazyky.
- Nový placený balíček: IAP produkt v ASC / Play Console a záznam v `assets/catalog.json` před `make ship`.
- Žádný widget nejmenuje font family; vše přes `AppTheme` (`lib/theme/app_theme.dart`).
  Theme nesmí nést `wght` font variation (`test/app_theme_test.dart`).
- `app_en.arb` je šablona; každá další ARB musí mít stejné klíče (`test/l10n_test.dart`).
  Titulky balíčků v chrome jsou v UI jazyce, obsah karet v páru L1/L2.
- Uživatelské názvy stylů jsou v `lib/models/card_style.dart`, ne id z pipeline.

## Kam dál
- `docs/content-pipeline.md` — pipeline, styly, restyle knoby, shipping, remote catalog, `geo-flags`.
- `docs/architecture.md` — struktura appky, typografie, l10n, služby, legacy quiz generátor.
- `SKILL.md`, `README.md`, `Prompts/`.
