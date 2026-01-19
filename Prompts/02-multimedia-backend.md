# DuolingoCards - Multimedia Backend Plan

## Přehled
Golang backend pro generování multimédií (obrázky, audio, volitelně video) pro japonské flashcards pomocí AI API.

---

## Zvolená AI API

| Typ | Provider | Cena |
|-----|----------|------|
| **TTS** | ElevenLabs | ~$0.15/100 karet |
| **Obrázky** | Google Imagen 3 | ~$3.00/100 karet |
| **Celkem** | | ~$3.15/100 karet (~75 Kč) |

---

## Backend - Hotovo ✅

### Spuštění
```bash
cd backend
go run ./cmd/server
```

### API Endpoints
```
GET  /api/catalog                    # Seznam dostupných decků
GET  /api/decks/{id}/preview         # Náhled decku (5 karet)
GET  /api/decks/{id}                 # Celý deck
POST /api/decks/{id}/generate        # Spustit generování médií
GET  /api/decks/{id}/status          # Stav generování
POST /api/decks/{id}/download        # Stažení decku (pro IAP)
POST /api/receipts/verify            # Ověření IAP receiptu
```

### Konfigurace (.env)
```bash
PORT=8080
ELEVENLABS_API_KEY=your_key
GOOGLE_API_KEY=your_key
STORAGE_PATH=./media
STORAGE_BASE_URL=http://localhost:8080/media

# IAP validace
APPLE_SHARED_SECRET=your_apple_shared_secret
GOOGLE_PACKAGE_NAME=com.example.duolingocards
IAP_SANDBOX_MODE=true
```

### Struktura projektu
```
backend/
├── cmd/server/main.go
├── internal/
│   ├── api/           # HTTP handlers + routes
│   ├── models/        # Card, Deck, Catalog
│   ├── services/      # Generator, TTS, Image clients
│   ├── storage/       # Local filesystem storage
│   └── config/        # Environment config
├── media/
│   └── decks/         # JSON decky + vygenerovaná média
└── go.mod
```

---

## Distribuce a monetizace

### Zvolená strategie
- **1 deck zdarma** (bundled v aplikaci)
- **Premium decky** jako Non-Consumable In-App Purchase
- AppStore/Google Play řeší platby (30% provize)

### Architektura
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   AppStore /    │     │   Backend API   │     │    Storage      │
│   Google Play   │     │    (Golang)     │     │   (S3/R2)       │
│                 │     │                 │     │                 │
│  - IAP validace │◄───►│  - Deck catalog │◄───►│  - Deck JSON    │
│  - Receipts     │     │  - Download API │     │  - Media files  │
└─────────────────┘     │  - Receipt check│     └─────────────────┘
                        └─────────────────┘
                                ▲
                                │
                        ┌───────┴───────┐
                        │  Flutter App  │
                        │               │
                        │ - Deck browser│
                        │ - IAP flow    │
                        │ - Local cache │
                        └───────────────┘
```

---

## Další kroky

### Fáze 1: Backend základ ✅
- [x] Go modul + modely
- [x] HTTP server + routes
- [x] ElevenLabs TTS client
- [x] Google Imagen client
- [x] Generator service
- [x] Local storage

### Fáze 2: Produkce (TODO)
- [ ] S3/Cloudflare R2 storage
- [x] IAP receipt validation (Apple + Google)
- [ ] Deployment (Railway/Fly.io)

### Fáze 3: Flutter integrace ✅
- [x] ApiService - volání backend API
- [x] LocalDeckService - lokální storage decků
- [x] HomeScreen - seznam decků + navigace do Store
- [x] DeckStoreScreen - katalog, preview, stahování
- [x] FlashcardWidget - podpora obrázků a audia
- [x] In-app purchase integrace

---

## Flutter - nové soubory

```
lib/
├── models/
│   └── catalog.dart              # CatalogItem, DeckPreview
├── services/
│   ├── api_service.dart          # HTTP client pro backend
│   ├── local_deck_service.dart   # Lokální storage decků
│   └── iap_service.dart          # In-App Purchase integrace
├── screens/
│   ├── home_screen.dart          # Seznam decků
│   └── deck_store_screen.dart    # Deck Store UI + IAP
└── widgets/
    └── flashcard_widget.dart     # Aktualizováno pro obrázky/audio
```

---

## Testování backendu

```bash
# Spustit server
cd backend && go run ./cmd/server

# Katalog decků
curl http://localhost:8080/api/catalog

# Preview decku
curl http://localhost:8080/api/decks/japanese-basics/preview

# Celý deck
curl http://localhost:8080/api/decks/japanese-basics

# Generovat média (vyžaduje API klíče)
curl -X POST http://localhost:8080/api/decks/japanese-basics/generate

# Ověřit IAP receipt
curl -X POST http://localhost:8080/api/receipts/verify \
  -H "Content-Type: application/json" \
  -d '{"platform":"ios","receiptData":"...","productId":"com.example.duolingocards.deck.japanese-n5","deckId":"japanese-n5"}'
```

---

## Nastavení IAP produktů

### App Store Connect (iOS)

1. Přihlásit se na [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → Vaše aplikace → In-App Purchases
3. Vytvořit nový Non-Consumable produkt:
   - Product ID: `com.example.duolingocards.deck.<deck-id>`
   - Reference Name: název decku
   - Cena: zvolit tier
4. Získat Shared Secret pro validaci:
   - App Information → App-Specific Shared Secret
   - Nastavit jako `APPLE_SHARED_SECRET` v .env

### Google Play Console (Android)

1. Přihlásit se na [Google Play Console](https://play.google.com/console)
2. Vaše aplikace → Monetizace → Produkty → Přidat produkt
3. Vytvořit nový In-app product:
   - Product ID: `com.example.duolingocards.deck.<deck-id>`
   - Typ: Managed product (non-consumable)
   - Cena: nastavit
4. Pro server-side validaci:
   - Nastavit Service Account pro Google Play Developer API
   - Nebo použít sandbox mode pro vývoj
