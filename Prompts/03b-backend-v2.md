# DuolingoCards — implementační plán v2 (no-backend)

> **Nahrazuje runtime vrstvu** plánu v1 i IAP dodatku. Co zůstává v platnosti: seznam 20 jazyků, lokalizační vrstvy (tier 0–3) a nápady na decky.
> Klíčová rozhodnutí: **žádný runtime backend**, IAP odemyká obsah on-device, výslovnost přes `flutter_tts`, obrázkové packy hostuje Apple/Google.

---

## 1. Architektura v kostce

```
BUILD-TIME (tvůj stroj — běží jen když tvoříš obsah; vše po lokální síti)
  Git repo souborů na disku (deck-per-folder)
      ├─ LLM (Spark)      → text: label + summary + info ×20 jazyků (i18n/*.yaml)
      └─ ComfyUI (Spark)  → obrázky: FLUX i Pony (duální prompting), bez Cloudflare
            │
            ▼  build (merge + validate)
  per-deck packy:  deck.json (texty 20 jazyků) + images/<style>/*.webp
            │
            ▼  zabalení do buildu
  iOS On-Demand Resources  /  Android Play Asset Delivery

RUNTIME (jen telefon — žádný tvůj server)
  Flutter app
    ├─ IAP:  StoreKit 2 / Play Billing  (ověření on-device, restore přes store)
    ├─ obsah: free decky v binárce, placené přes ODR/PAD po koupi
    ├─ výslovnost: flutter_tts (OS hlasy, nula audio assetů)
    └─ cache: Hive
```

Žádný Postgres, CDN, `cards-api`, entitlement server ani webhooky — autorský obsah jsou jen soubory v Gitu. Tvoje Spark pipeline (ComfyUI + LLM) **nemizí** — běží po LAN jako build-time krok, jen se z ní nestává veřejná služba.

---

## 2. Rozsah a velikost

| Entita | Počet | Velikost |
|---|---|---|
| Decky | 100 | — |
| Karty | 5 000 | — |
| Texty (label + summary + info ×20) | ~300 000 polí | ~10–40 MB JSON |
| Obrázky (webp) | ~5 000 × počet stylů | ~150–300 MB / styl |
| **Audio** | **0** | **0** (on-device TTS) |

Bez audia je celkový obsah ~čtvrt giga. To otevírá dvě cesty distribuce (sekce 6) — a ani „všechno do binárky" už není nereálné.

---

## 3. Cílové jazyky (top 20) + pokrytí TTS

Seznam a locale kódy beze změny z v1 (`en, zh-CN, hi, es-419, ar, fr, bn, pt-BR, ru, id, ur, de, ja, mr, te, tr, ta, vi, ko, ha`).

**Nové u no-backend:** výslovnost závisí na OS hlasech, ne na tobě.
- Při startu/renderu karty volej `flutter_tts.isLanguageAvailable(lang)`.
- Některé jazyky nemusí mít hlas na všech zařízeních (riziko zejm. `ha`, `te`, `mr`, `bn`, `ur` na starších Androidech).
- Fallback politika (rozhodnutí v sekci 12): buď tlačítko „přehrát" skryj, když hlas chybí, nebo na iOS vyzvi ke stažení rozšířeného hlasu.
- **RTL** (`ar`, `ur`): `Directionality` v appce i v autorské preview.

---

## 4. Obsah: build-time pipeline (žádný runtime server)

Pipeline běží **offline u tebe**, přes lokální síť na Spark (ComfyUI + LLM), **bez Cloudflare**, a na konci **exportuje statické soubory**.

### 4.1 Textový obsah — kartička je výuková, ne jen překlad
Každý koncept má ve **všech 20 jazycích** tři pole (kterýkoli jazyk může být pro uživatele rodný i cizí):

- `label` — slovo (překlad)
- `summary` — krátké shrnutí (1–2 věty), ukazuje se v **cizím** jazyce
- `info` — plný výukový text, ukazuje se v **rodném** jazyce

Zobrazovací logika pro pár (rodný L1 → cizí L2): na straně cizího jazyka `label[L2]` + `summary[L2]`, na straně rodného `label[L1]` + `info[L1]`. Proto musí být `summary` i `info` ve všech 20 jazycích.

**Kritické rozhodnutí kvality — fakta autoruj jen jednou.** `info` a `summary` jsou faktická tvrzení (kde lev žije, co jí…). Generovat je nezávisle ve 20 jazycích = 20× riziko halucinace a nemožnost to odchytit v jazycích, kterými nemluvíš.
→ **Autoruj `info`+`summary` v jednom pivotu (en nebo cs), fakticky zkontroluj pivot, teprve pak přelož do zbylých 19.** Jedna kontrola pokryje všechny jazyky a fakta zůstanou konzistentní. `label` se překládá samostatně (jednoslovné, s `hint` na disambiguaci).

### 4.2 Obrázky — ComfyUI, duální prompting (FLUX + Pony)
FLUX a Pony chtějí jiný formát promptu, takže nepiš 5 000× dva prompty ručně. LLM vygeneruje per koncept **vizuální brief**, ten se šablonou přeloží do obou formátů:

```jsonc
// vizuální brief (LLM) → sémantický popis, ne hotový prompt
{ "subject": "lion", "attrs": ["friendly","sitting"], "setting": "savanna grass", "avoid": ["text","blood"] }
```

- **FLUX:** přirozená věta + stylový suffix; distilovaný FLUX prakticky ignoruje negativní prompt → vše patří do pozitivního promptu.
- **Pony:** `score_9, score_8_up, …` + danbooru-style tagy + **plný negativní prompt** (`text, watermark, realistic, …`).
- Přidání dalšího backendu/stylu = jen nová šablona nad stejným briefem.

### 4.3 Styly a varianty decku (volitelné, navrženo dopředu)
Odděl **jazykovou vrstvu** (label/summary/info) od **vizuální vrstvy** (obrázky). Díky tomu jde multi-styl přidat skoro zadarmo kdykoli později — regeneruješ jen obrázky pod novým stylem, drahá jazyková vrstva je sdílená.

- Obrázek je klíčovaný `(concept, style, region)`. `style` = pojmenovaná konfigurace (backend + šablona promptu + suffix), např. `flux-real`, `pony-cartoon`.
- Možné využití (rozhodneš později): přepínač stylu v UI, nebo stejný deck prodávaný ve dvou vizuálech jako různé produkty.
- **Teď nemusíš generovat nic navíc** — stačí, že model i export počítají s dimenzí `style` (default jeden styl).

### 4.4 Úložiště: soubory na disku v Gitu (žádná DB)
Autorský obsah jsou prosté soubory, **jeden folder per deck**, verzované Gitem. Proti DB tím získáš historii, diffy, rollback a ruční editovatelnost zadarmo; pro 100 decků × 50 karet je relační DB zbytečná.

```
decks/
  animals-wild/
    deck.yaml              # meta + karty: concept_key, hint, vizuální brief (jazykově neutrální)
    i18n/
      en.yaml              # label + summary + info pro všech 50 karet (pivot)
      cs.yaml
      te.yaml  … (20 jazyků)
    images/
      flux-real/animal.lion.webp
```

- **YAML pro autoring** (komentáře, víceřádkový `info` přes blokový skalár `|`), **JSON jako build výstup**.
- **i18n per jazyk:** review/regenerace jednoho jazyka = jeden soubor; pivot-then-translate (4.1) sedí 1:1 — vyrobíš `en.yaml`, z něj zbylých 19.
- **Validace nahrazuje DB constraints.** Přidej `lint` krok (Go/Python, běží v CI / pre-commit): každý jazyk má všechny `concept_key`, každý obrázek existuje, schéma sedí. To je jediná věc, kterou proti DB dorovnáváš.
- **Binárky ven z text repa.** webp přes git-lfs nebo mimo git (sync z Sparku do build adresáře), ať se text repo nenafoukne.
- **Review = Git** (PR/historie) + lint. Žádný admin endpoint ani status tabulka.

**Build = merge + validate:** skript složí per-jazyk YAML do runtime `deck.json` a sestaví ODR/PAD packy. Tohle je celý „export":

```jsonc
// build výstup: deck "animals-wild" → deck.json
{
  "deck": "animals-wild", "version": 7, "styles": ["flux-real"],
  "titles": { "en": "Wild animals", "cs": "Divoká zvířata" },
  "cards": [
    { "key": "animal.lion", "image": "animal.lion.webp",
      "label":   { "en": "lion", "cs": "lev", "ar": "أسد" },
      "summary": { "en": "A big wild cat from Africa.", "cs": "Velká kočkovitá šelma z Afriky." },
      "info":    { "en": "Lions live in...", "cs": "Lvi žijí v..." } }
  ]
}
```

---

## 5. Výslovnost: on-device TTS

- Plugin `flutter_tts`. Přehrání = `await tts.setLanguage(lang); await tts.speak(label);` (volitelně přečti i `summary`).
- Nula assetů, nula hostingu, funguje offline (pokud má OS daný hlas).
- Mapuj BCP-47 na to, co `flutter_tts` čeká (`getLanguages` vrací dostupné); drž malou převodní tabulku pro varianty (`es-419 → es-MX/es-ES` podle dostupnosti).

---

## 6. Distribuce obsahu (dvě varianty)

### A — Base binárka + ODR/PAD  *(doporučeno)*
- Do binárky jdou jen **free decky** + appka → malá instalace = vyšší konverze na tvých trzích.
- Placené decky = **iOS On-Demand Resources** (ODR tagy) / **Android Play Asset Delivery** (asset packs). Hostuje **Apple/Google zdarma**, stáhne se až po koupi.
- IAP odemkne → appka si vyžádá příslušný ODR tag / PAD pack → stáhne → Hive.

### B — Vše v binárce  *(nejjednodušší)*
- ~250–300 MB do jedné binárky. Technicky průchozí (bez audia). Méně práce, ale větší initial download.
- IAP pak jen lokálně odemkne přístup k obsahu, který už v appce leží.

Bez audia je rozdíl mezi A a B hlavně o velikosti instalace vs. jednoduchosti. Pro globální trh (Brazílie, Afrika, Indie) bych šel do **A**.

---

## 7. IAP bez backendu

```
Flutter (in_app_purchase plugin)
  → StoreKit 2 (iOS) / Play Billing (Android)
  → nákup proběhne, transakce se ověří ON-DEVICE
       ├─ iOS: StoreKit 2 ověří JWS podpis Applu lokálně
       └─ Android: Play Billing + lokální kontrola
  → appka lokálně odemkne deck(y) a (varianta A) spustí ODR/PAD download
  → entitlement uložen v Hive; zdroj pravdy je store (Restore kdykoli přepočítá)
```

- **Produkt → decky** je lokální `catalog.json` zabalený v appce (mapuje store SKU per platforma na deck slugy + označuje free decky). Žádná DB.
- **Restore Purchases:** plugin se zeptá store na vlastněné produkty → appka přepočítá odemčené decky. Funguje cross-device i po reinstalaci, bez tvého serveru.
- **Volitelně RevenueCat:** pokud chceš jednotnou evidenci nákupů napříč iOS/Android bez vlastní logiky — je to „backend, který nehostuješ". Čistý StoreKit/Billing ale stačí.

```jsonc
// catalog.json (v appce)
{
  "free": ["numbers", "colors", "shapes", "animals-pets"],
  "products": [
    { "code": "pack.animals.mega",
      "sku": { "apple": "com.ol1n.cards.animals", "google": "pack_animals_mega" },
      "unlocks": ["animals-wild", "animals-sea", "animals-birds"] }
  ]
}
```

---

## 8. Lokalizační vrstvy

Beze změny z v1 (tier 0–3). Jediný rozdíl: tier 2 region je další dimenze obrázku `(concept, style, region)` — varianty se balí jako samostatné ODR/PAD packy, případně se region napeče přímo do varianty decku. Appka zná locale uživatele a stáhne odpovídající variantu.

---

## 9. Flutter struktura

- **Riverpod** stav: katalog, entitlements, stav stažení packů.
- **Hive:** cache rozbalených decků + lokální entitlement flagy.
- **in_app_purchase:** nákupy + restore.
- **ODR/PAD:** iOS přes `NSBundleResourceRequest` (přes platform channel nebo plugin), Android přes Play Asset Delivery API.
- **flutter_tts:** výslovnost + `isLanguageAvailable` fallback.
- **RTL:** `Directionality` podle jazyka karty.

---

## 10. Co jsme oproti server verzi obětovali (poctivě)

- **Změna obsahu = nový release do storu.** Nelze hotfixnout překlep bez app update. Obsah je ale po dotvoření stabilní → v praxi OK.
- **Slabší ochrana proti podvodu.** On-device ověření jde na jailbreaknutém/rootnutém zařízení obejít. Pro kartičky pro děti zanedbatelné.
- **Žádná tvoje analytika.** Co se používá → dořeš Firebase/RevenueCat, ne vlastním serverem.
- **TTS kvalita kolísá** podle OS/jazyka — výměnou za nulovou váhu a nulový hosting.

---

## 11. Milníky

- **M0 — Autorská pipeline.** Git repo + file schéma (`deck.yaml` + `i18n/*.yaml`) + `lint` a `build` tooling (merge YAML → `deck.json`, validace, assembly ODR/PAD).
- **M1 — Seed + 3 piloty.** 1× tier 0 (zvířata), 1× tier 1 (emoce), 1× tier 2 (snídaně).
- **M2 — Texty.** Pivot autoring `info`+`summary`, **faktická kontrola pivotu**, pak překlad `label`/`summary`/`info` do 20 jazyků.
- **M3 — Obrázky.** Vizuální brief → ComfyUI FLUX + Pony (duální prompt), 1 default styl, dimenze `style` připravená.
- **M4 — Review (Git/lint) + build layout** pro ODR/PAD.
- **M5 — Flutter core.** Render decku, Hive cache, `flutter_tts` + fallback, RTL.
- **M6 — Distribuce.** Base binárka (free decky) + ODR/PAD pro placené (varianta A).
- **M7 — IAP.** `in_app_purchase`, StoreKit 2 / Play Billing on-device, restore, `catalog.json` mapování.
- **M8 — Plný build + launch.** Vygeneruj všech 100 decků, produkty v App Store Connect + Play Console, QA na top 5 jazycích a 4 trzích, postupné publikování.

---

## 12. Otevřená rozhodnutí

1. **Distribuce A vs B** — ODR/PAD split (doporučeno pro konverzi) vs vše v binárce (~300 MB, nejjednodušší). Bez audia je proveditelné obojí.
2. **TTS fallback** — když chybí OS hlas pro jazyk: skrýt tlačítko, nebo vyzvat ke stažení hlasu?
3. **RevenueCat vs čistý StoreKit/Billing** — chceš jednotnou evidenci napříč platformami, nebo to držet úplně bez závislosti?
4. **Cenový model** — free trychtýř + bundly (doporučeno) vs à la carte vs subscription. (Beze změny z dodatku.)
5. **Multi-styl** — jeden vizuál teď, nebo rovnou víc stylů / stejný deck ve dvou vizuálech? Model i export to umožní kdykoli; teď stačí default styl.
6. **Pivot pro fakta** — `en` nebo `cs` jako jazyk, ve kterém autoruješ a kontroluješ `info`/`summary` před překladem?
