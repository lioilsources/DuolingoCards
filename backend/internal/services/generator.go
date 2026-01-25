package services

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"

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

		// First deck is free, others are paid
		if deck.ID == "japanese-basics" {
			item.Price = "free"
		} else {
			item.Price = "tier1"
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

	previewCount := 5
	if len(deck.Cards) < previewCount {
		previewCount = len(deck.Cards)
	}

	return &models.DeckPreview{
		ID:            deck.ID,
		Name:          deck.Name,
		Description:   deck.Description,
		FrontLanguage: deck.FrontLanguage,
		BackLanguage:  deck.BackLanguage,
		TotalCards:    len(deck.Cards),
		PreviewCards:  deck.Cards[:previewCount],
	}, nil
}

func (g *Generator) GetDeck(deckID string) (*models.Deck, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	deck, ok := g.decks[deckID]
	if !ok {
		return nil, fmt.Errorf("deck not found: %s", deckID)
	}

	return deck, nil
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

	for i := range deck.Cards {
		card := &deck.Cards[i]

		// Generate TTS for frontLanguage (the language being learned)
		if g.ttsClient != nil {
			audioData, err := g.ttsClient.GenerateSpeech(card.FrontText, deck.TTSVoiceID)
			if err == nil {
				url, err := g.storage.Save(deck.ID, card.ID, "audio.mp3", audioData)
				if err == nil {
					if card.Media == nil {
						card.Media = &models.Media{}
					}
					card.Media.AudioFront = url
				}
			}
		}

		// Generate illustration using template
		if g.imageClient != nil {
			prompt := buildImagePrompt(imageTemplate, card)
			imageData, err := g.imageClient.GenerateImage(prompt)
			if err == nil {
				url, err := g.storage.Save(deck.ID, card.ID, "image.png", imageData)
				if err == nil {
					if card.Media == nil {
						card.Media = &models.Media{}
					}
					card.Media.Image = url
				}
			}
		}

		card.MediaStatus = "ready"

		g.mu.Lock()
		status.Progress = i + 1
		g.mu.Unlock()
	}

	g.mu.Lock()
	status.Status = "completed"
	g.saveDeck(deck)
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
