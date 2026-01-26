package services

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/example/duolingocards-backend/internal/config"
	"github.com/example/duolingocards-backend/internal/models"
	"github.com/example/duolingocards-backend/internal/services/image"
	"github.com/example/duolingocards-backend/internal/services/tts"
	"github.com/example/duolingocards-backend/internal/storage"
)

const defaultImagePromptTemplate = "Simple, clean illustration for vocabulary flashcard showing '{word}'. Minimalist, colorful icon-style. No text, no letters. White background."

type Generator struct {
	ttsClient    *tts.ElevenLabsClient
	imageClient  *image.ImagenClient
	storage      *storage.LocalStorage
	cfg          *config.Config

	// In-memory deck storage (replace with DB in production)
	decks    map[string]*models.Deck
	statuses map[string]*models.GenerateStatus
	mu       sync.RWMutex
}

func NewGenerator(cfg *config.Config) *Generator {
	g := &Generator{
		cfg:      cfg,
		decks:    make(map[string]*models.Deck),
		statuses: make(map[string]*models.GenerateStatus),
		storage:  storage.NewLocalStorage(cfg.StoragePath, cfg.StorageBaseURL),
	}

	if cfg.ElevenLabsKey != "" {
		g.ttsClient = tts.NewElevenLabsClient(cfg.ElevenLabsKey)
	}

	if cfg.GoogleAPIKey != "" {
		g.imageClient = image.NewImagenClient(cfg.GoogleAPIKey)
	}

	// Load existing decks from storage
	g.loadDecksFromStorage()

	return g
}

func (g *Generator) loadDecksFromStorage() {
	decksPath := filepath.Join(g.cfg.StoragePath, "decks")
	entries, err := os.ReadDir(decksPath)
	if err != nil {
		// Directory doesn't exist yet, create it
		os.MkdirAll(decksPath, 0755)
		return
	}

	for _, entry := range entries {
		if !entry.IsDir() && filepath.Ext(entry.Name()) == ".json" {
			data, err := os.ReadFile(filepath.Join(decksPath, entry.Name()))
			if err != nil {
				continue
			}

			var deck models.Deck
			if err := json.Unmarshal(data, &deck); err != nil {
				continue
			}

			g.decks[deck.ID] = &deck
		}
	}
}

func (g *Generator) saveDeck(deck *models.Deck) error {
	decksPath := filepath.Join(g.cfg.StoragePath, "decks")
	os.MkdirAll(decksPath, 0755)

	data, err := json.MarshalIndent(deck, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(filepath.Join(decksPath, deck.ID+".json"), data, 0644)
}

func (g *Generator) GetCatalog() *models.Catalog {
	g.mu.RLock()
	defer g.mu.RUnlock()

	catalog := &models.Catalog{Decks: []models.CatalogItem{}}

	for _, deck := range g.decks {
		item := models.CatalogItem{
			ID:          deck.ID,
			Name:        deck.Name,
			Description: deck.Description,
			CardCount:   len(deck.Cards),
			Languages:   []string{deck.FrontLanguage, deck.BackLanguage},
		}

		// Use price from deck JSON, default to "tier1" if not set
		if deck.Price != "" {
			item.Price = deck.Price
		} else {
			item.Price = "tier1"
		}

		// Add IAP product ID for paid decks
		if item.Price != "free" {
			item.IAPProductID = fmt.Sprintf("com.example.deck.%s", deck.ID)
		}

		catalog.Decks = append(catalog.Decks, item)
	}

	return catalog
}

func (g *Generator) GetDeckPreview(deckID string) (*models.DeckPreview, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	deck, ok := g.decks[deckID]
	if !ok {
		return nil, fmt.Errorf("deck not found: %s", deckID)
	}

	// Get versioned deck copy
	versionedDeck := g.addVersionToMediaURLs(deck)

	previewCount := 5
	if len(versionedDeck.Cards) < previewCount {
		previewCount = len(versionedDeck.Cards)
	}

	return &models.DeckPreview{
		ID:            versionedDeck.ID,
		Name:          versionedDeck.Name,
		Description:   versionedDeck.Description,
		FrontLanguage: versionedDeck.FrontLanguage,
		BackLanguage:  versionedDeck.BackLanguage,
		TotalCards:    len(versionedDeck.Cards),
		PreviewCards:  versionedDeck.Cards[:previewCount],
	}, nil
}

func (g *Generator) GetDeck(deckID string) (*models.Deck, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	deck, ok := g.decks[deckID]
	if !ok {
		return nil, fmt.Errorf("deck not found: %s", deckID)
	}

	// Return a copy with versioned URLs to prevent cache issues
	return g.addVersionToMediaURLs(deck), nil
}

// addVersionToMediaURLs creates a copy of the deck with version query params on media URLs
func (g *Generator) addVersionToMediaURLs(deck *models.Deck) *models.Deck {
	if deck.Version == 0 {
		return deck
	}

	// Create a shallow copy of the deck
	deckCopy := *deck
	deckCopy.Cards = make([]models.Card, len(deck.Cards))

	versionSuffix := fmt.Sprintf("?v=%d", deck.Version)

	for i, card := range deck.Cards {
		cardCopy := card
		if card.Media != nil {
			mediaCopy := *card.Media
			if mediaCopy.Image != "" {
				mediaCopy.Image = mediaCopy.Image + versionSuffix
			}
			if mediaCopy.AudioFront != "" {
				mediaCopy.AudioFront = mediaCopy.AudioFront + versionSuffix
			}
			if mediaCopy.AudioBack != "" {
				mediaCopy.AudioBack = mediaCopy.AudioBack + versionSuffix
			}
			cardCopy.Media = &mediaCopy
		}
		deckCopy.Cards[i] = cardCopy
	}

	return &deckCopy
}

func (g *Generator) StartGeneration(req models.GenerateRequest) (*models.GenerateStatus, error) {
	g.mu.Lock()

	deck, ok := g.decks[req.DeckID]
	if !ok {
		g.mu.Unlock()
		return nil, fmt.Errorf("deck not found: %s", req.DeckID)
	}

	status := &models.GenerateStatus{
		DeckID:     req.DeckID,
		Status:     "generating",
		Progress:   0,
		TotalCards: len(deck.Cards),
	}
	g.statuses[req.DeckID] = status
	g.mu.Unlock()

	// Start generation in background
	go g.generateMedia(deck, status)

	return status, nil
}

func (g *Generator) generateMedia(deck *models.Deck, status *models.GenerateStatus) {
	// Get image prompt template (use default if not set)
	imageTemplate := deck.ImagePromptTemplate
	if imageTemplate == "" {
		imageTemplate = defaultImagePromptTemplate
	}

	log.Printf("Starting media generation for deck %s (%d cards)", deck.ID, len(deck.Cards))
	log.Printf("TTS client: %v, Image client: %v", g.ttsClient != nil, g.imageClient != nil)

	for i := range deck.Cards {
		card := &deck.Cards[i]
		cardIndex := i + 1 // 1-based index for filenames
		log.Printf("Processing card %d/%d: %s", cardIndex, len(deck.Cards), card.FrontText)

		// Generate TTS for frontLanguage (the language being learned)
		// Use reading (romaji) for audio filename: "01-konnichiwa-audio.mp3"
		if g.ttsClient != nil {
			audioSlug := card.Reading
			if audioSlug == "" {
				audioSlug = card.FrontText // Fallback to frontText if no reading
			}
			audioFilename := storage.BuildMediaFilename(cardIndex, audioSlug, "audio", "mp3")

			// Check if audio file already exists on disk
			if g.storage.ExistsFlat(deck.ID, audioFilename) {
				url := g.storage.BuildURL(deck.ID, audioFilename)
				if card.Media == nil {
					card.Media = &models.Media{}
				}
				card.Media.AudioFront = url
				log.Printf("  TTS exists, skipping API call: %s", audioFilename)
			} else {
				log.Printf("  Generating TTS for: %s -> %s", card.FrontText, audioFilename)
				audioData, err := g.ttsClient.GenerateSpeech(card.FrontText, deck.TTSVoiceID)
				if err != nil {
					log.Printf("  TTS error: %v", err)
				} else {
					url, err := g.storage.SaveFlat(deck.ID, audioFilename, audioData)
					if err != nil {
						log.Printf("  Storage error (audio): %v", err)
					} else {
						if card.Media == nil {
							card.Media = &models.Media{}
						}
						card.Media.AudioFront = url
						log.Printf("  TTS saved: %s", url)
					}
				}
			}
		} else {
			log.Printf("  Skipping TTS - no client configured")
		}

		// Generate illustration using template
		// Use backText (translation) for image filename: "01-dobry-den-image.png"
		if g.imageClient != nil {
			imageFilename := storage.BuildMediaFilename(cardIndex, card.BackText, "image", "png")

			// Check if image file already exists on disk
			if g.storage.ExistsFlat(deck.ID, imageFilename) {
				url := g.storage.BuildURL(deck.ID, imageFilename)
				if card.Media == nil {
					card.Media = &models.Media{}
				}
				card.Media.Image = url
				log.Printf("  Image exists, skipping API call: %s", imageFilename)
			} else {
				prompt := buildImagePrompt(imageTemplate, card)
				log.Printf("  Generating image with prompt: %s -> %s", prompt, imageFilename)
				imageData, err := g.imageClient.GenerateImage(prompt)
				if err != nil {
					log.Printf("  Image error: %v", err)
				} else {
					url, err := g.storage.SaveFlat(deck.ID, imageFilename, imageData)
					if err != nil {
						log.Printf("  Storage error (image): %v", err)
					} else {
						if card.Media == nil {
							card.Media = &models.Media{}
						}
						card.Media.Image = url
						log.Printf("  Image saved: %s", url)
					}
				}
			}
		} else {
			log.Printf("  Skipping image - no client configured")
		}

		card.MediaStatus = "ready"

		g.mu.Lock()
		status.Progress = i + 1
		g.mu.Unlock()
	}

	g.mu.Lock()
	status.Status = "completed"
	deck.Version = time.Now().Unix() // Update version for cache busting
	g.saveDeck(deck)
	log.Printf("Media generation completed for deck %s (version: %d)", deck.ID, deck.Version)
	g.mu.Unlock()
}

// buildImagePrompt replaces placeholders in template with card values
// Supported placeholders: {word}, {front}, {back}, {reading}
func buildImagePrompt(template string, card *models.Card) string {
	prompt := template
	prompt = strings.ReplaceAll(prompt, "{word}", card.BackText)  // Use backText (translation) for image
	prompt = strings.ReplaceAll(prompt, "{front}", card.FrontText)
	prompt = strings.ReplaceAll(prompt, "{back}", card.BackText)
	prompt = strings.ReplaceAll(prompt, "{reading}", card.Reading)
	return prompt
}

func (g *Generator) GetStatus(deckID string) (*models.GenerateStatus, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	status, ok := g.statuses[deckID]
	if !ok {
		return nil, fmt.Errorf("no generation status for deck: %s", deckID)
	}

	return status, nil
}

// CreateDeck creates a new deck (for admin use)
func (g *Generator) CreateDeck(deck *models.Deck) error {
	g.mu.Lock()
	defer g.mu.Unlock()

	g.decks[deck.ID] = deck
	return g.saveDeck(deck)
}
