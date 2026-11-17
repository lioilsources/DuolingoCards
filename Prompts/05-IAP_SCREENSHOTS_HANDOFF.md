# 05 — Handoff pro MacBook: review screenshoty balíčku „Všechny balíčky“

Pro session na MacBooku (Xcode + simulátor). Na M2 se screenshoty nedělají (DevConventions
`shared/stacks/flutter.md`).

## Proč

V App Store Connect je 5 nových produktů balíčku „Všechny balíčky“ (PR #18, popis
`store/README.md`). Všechny jsou ve stavu MISSING_METADATA, protože jim chybí jen review
screenshot.

| Produkt | Cena | Nabízí se, když uživatel vlastní |
|---|---|---|
| `com.ol1n.duolingocards.decks_all` | 4,99 USD | 0 placených balíčků |
| `com.ol1n.duolingocards.decks_all_s1` | 3,99 USD | 1 |
| `com.ol1n.duolingocards.decks_all_s2` | 2,99 USD | 2 |
| `com.ol1n.duolingocards.decks_all_s3` | 1,99 USD | 3 |
| `com.ol1n.duolingocards.decks_all_s4` | 0,99 USD | 4 a víc |

Starší `com.ol1n.duolingocards.bundle.all` se nepoužívá, screenshot nepotřebuje.

## Co udělat

1. Kód je v PR #18. Je-li mergnutý, `git pull` na `main`; jinak `git checkout
   feat/complete-the-set`.
2. **Lokální StoreKit konfigurace, ne sandbox.** Produkty v MISSING_METADATA se v sandboxu
   nenačtou. Ve schématu Runner zapni StoreKit konfigurační soubor (Run → Options → StoreKit
   Configuration); pokud v repu žádný není, založ `ios/Lexify.storekit` s placenými balíčky
   z `assets/catalog.json` a pěti produkty z tabulky (non-consumable, ceny z tabulky).
3. Spusť appku na simulátoru **iPhone 6.9"** (např. iPhone 16 Pro Max), angličtina.
4. Otevři detail placeného balíčku s tlačítkem **All decks**:
   - `decks_all.png`: nic koupeno, cena 4,99 bez přeškrtnutí.
   - `decks_all_s2.png`: nejdřív kup 2 balíčky (lokální StoreKit), pak vyfoť detail třetího.
     Cena 2,99, přeškrtnuté 4,99, řádek o odečtení.
5. Ulož do `store/review_screenshots/` vedle stávajících a pushni (soubory jmenovitě).
6. Pošli session **Store** zprávu s cestou. Store nahraje review screenshoty:
   - `decks_all.png` → `decks_all`;
   - `decks_all_s2.png` → `decks_all_s1` až `_s4`.

## Hotovo, když

Oba PNG jsou v repu a Store potvrdí, že produkty přešly z MISSING_METADATA do READY_TO_SUBMIT.

Nic neodesílej k review a neměň produkty v ASC. Verze s produkty vyjde až s novými balíčky
a ikonou.
