package deck

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/duolingocards/quiz-generator/internal/generator"
)

// Deck represents a flashcard deck.
type Deck struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Description   string `json:"description"`
	CardType      string `json:"cardType"`
	FrontLanguage string `json:"frontLanguage"`
	BackLanguage  string `json:"backLanguage"`
	MediaBaseURL  string `json:"mediaBaseUrl,omitempty"`
	Cards         []Card `json:"cards"`
}

// Card represents a flashcard in the deck.
type Card struct {
	ID        string    `json:"id"`
	Type      string    `json:"type"`
	FrontText string    `json:"frontText"`
	BackText  string    `json:"backText"`
	Media     *Media    `json:"media,omitempty"`
	QuizData  *QuizData `json:"quizData,omitempty"`
}

// Media represents card media assets.
type Media struct {
	Image string `json:"image,omitempty"`
}

// QuizData represents quiz-specific data.
type QuizData struct {
	Category   string            `json:"category"`
	Title      string            `json:"title"`
	Subtitle   string            `json:"subtitle,omitempty"`
	Fields     []generator.Field `json:"fields,omitempty"`
	WikidataID string            `json:"wikidataId,omitempty"`
}

// Builder helps construct decks from quiz items.
type Builder struct {
	deck Deck
}

// NewBuilder creates a new deck builder.
func NewBuilder(id, name, description, backLang, mediaBaseURL string) *Builder {
	return &Builder{
		deck: Deck{
			ID:            id,
			Name:          name,
			Description:   description,
			CardType:      "quiz",
			FrontLanguage: "visual",
			BackLanguage:  backLang,
			MediaBaseURL:  mediaBaseURL,
			Cards:         []Card{},
		},
	}
}

// AddCard adds a card from a quiz item.
func (b *Builder) AddCard(item generator.QuizItem, category string) {
	card := Card{
		ID:        item.ID,
		Type:      "quiz",
		FrontText: "",
		BackText:  item.Title,
	}

	if item.LocalImage != "" {
		card.Media = &Media{
			Image: item.LocalImage,
		}
	}

	card.QuizData = &QuizData{
		Category:   category,
		Title:      item.Title,
		Subtitle:   item.Subtitle,
		Fields:     item.Fields,
		WikidataID: item.WikidataID,
	}

	b.deck.Cards = append(b.deck.Cards, card)
}

// Build returns the constructed deck.
func (b *Builder) Build() *Deck {
	return &b.deck
}

// SaveJSON saves the deck to a JSON file.
func (b *Builder) SaveJSON(outputDir string) error {
	// Create output directory if needed
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("creating output directory: %w", err)
	}

	filePath := filepath.Join(outputDir, b.deck.ID+".json")
	file, err := os.Create(filePath)
	if err != nil {
		return fmt.Errorf("creating file: %w", err)
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(b.deck); err != nil {
		return fmt.Errorf("encoding deck: %w", err)
	}

	return nil
}
