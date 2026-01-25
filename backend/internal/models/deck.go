package models

type Deck struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Description   string `json:"description,omitempty"`
	FrontLanguage string `json:"frontLanguage"`
	BackLanguage  string `json:"backLanguage"`
	Cards         []Card `json:"cards"`
	MediaBaseURL  string `json:"mediaBaseUrl,omitempty"`

	// Media generation settings
	ImagePromptTemplate string `json:"imagePromptTemplate,omitempty"` // e.g. "Simple illustration of {word}, flat style"
	TTSVoiceID          string `json:"ttsVoiceId,omitempty"`          // ElevenLabs voice ID for frontLanguage
}

type CatalogItem struct {
	ID           string   `json:"id"`
	Name         string   `json:"name"`
	Description  string   `json:"description"`
	CardCount    int      `json:"cardCount"`
	Price        string   `json:"price"` // "free" or "tier1", "tier2", etc.
	IAPProductID string   `json:"iapProductId,omitempty"`
	ThumbnailURL string   `json:"thumbnailUrl,omitempty"`
	Languages    []string `json:"languages"`
}

type Catalog struct {
	Decks []CatalogItem `json:"decks"`
}

type DeckPreview struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Description   string `json:"description"`
	FrontLanguage string `json:"frontLanguage"`
	BackLanguage  string `json:"backLanguage"`
	TotalCards    int    `json:"totalCards"`
	PreviewCards  []Card `json:"previewCards"` // 3-5 sample cards
}

type GenerateRequest struct {
	DeckID string      `json:"deckId"`
	Cards  []CardInput `json:"cards,omitempty"` // Optional: specific cards to generate
}

type GenerateStatus struct {
	DeckID     string `json:"deckId"`
	Status     string `json:"status"` // pending, generating, completed, error
	Progress   int    `json:"progress"`
	TotalCards int    `json:"totalCards"`
	Error      string `json:"error,omitempty"`
}
