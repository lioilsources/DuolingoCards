package api

import (
	"encoding/json"
	"net/http"

	"github.com/example/duolingocards-backend/internal/config"
	"github.com/example/duolingocards-backend/internal/models"
	"github.com/example/duolingocards-backend/internal/services"
	"github.com/example/duolingocards-backend/internal/services/iap"
)

type Handlers struct {
	generator    *services.Generator
	iapValidator *iap.Validator
	cfg          *config.Config
}

func NewHandlers(generator *services.Generator, cfg *config.Config) *Handlers {
	return &Handlers{
		generator:    generator,
		iapValidator: iap.NewValidator(cfg.AppleSharedSecret, cfg.GooglePackageName, cfg.IAPSandboxMode),
		cfg:          cfg,
	}
}

func (h *Handlers) GetCatalog(w http.ResponseWriter, r *http.Request) {
	catalog := h.generator.GetCatalog()
	writeJSON(w, http.StatusOK, catalog)
}

func (h *Handlers) GetDeckPreview(w http.ResponseWriter, r *http.Request) {
	deckID := r.PathValue("id")
	if deckID == "" {
		writeError(w, http.StatusBadRequest, "deck id required")
		return
	}

	preview, err := h.generator.GetDeckPreview(deckID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, preview)
}

func (h *Handlers) GetDeck(w http.ResponseWriter, r *http.Request) {
	deckID := r.PathValue("id")
	if deckID == "" {
		writeError(w, http.StatusBadRequest, "deck id required")
		return
	}

	deck, err := h.generator.GetDeck(deckID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, deck)
}

func (h *Handlers) GenerateDeck(w http.ResponseWriter, r *http.Request) {
	deckID := r.PathValue("id")
	if deckID == "" {
		writeError(w, http.StatusBadRequest, "deck id required")
		return
	}

	var req models.GenerateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		// Empty body is OK, will generate all cards
		req = models.GenerateRequest{}
	}
	req.DeckID = deckID

	status, err := h.generator.StartGeneration(req)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusAccepted, status)
}

func (h *Handlers) GetGenerateStatus(w http.ResponseWriter, r *http.Request) {
	deckID := r.PathValue("id")
	if deckID == "" {
		writeError(w, http.StatusBadRequest, "deck id required")
		return
	}

	status, err := h.generator.GetStatus(deckID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, status)
}

func (h *Handlers) DownloadDeck(w http.ResponseWriter, r *http.Request) {
	deckID := r.PathValue("id")
	if deckID == "" {
		writeError(w, http.StatusBadRequest, "deck id required")
		return
	}

	// Parse download request
	var downloadReq struct {
		ReceiptData string `json:"receiptData"`
		Platform    string `json:"platform"`
	}
	if err := json.NewDecoder(r.Body).Decode(&downloadReq); err != nil {
		// Empty body is OK for free decks
		downloadReq = struct {
			ReceiptData string `json:"receiptData"`
			Platform    string `json:"platform"`
		}{}
	}

	// Check if this is a paid deck
	if iap.IsPaidDeck(deckID, h.cfg.FreeDecks) {
		// Validate receipt for paid decks
		verifyReq := iap.VerifyRequest{
			Platform:    downloadReq.Platform,
			ReceiptData: downloadReq.ReceiptData,
			ProductID:   "com.example.duolingocards.deck." + deckID,
			DeckID:      deckID,
		}

		result, err := h.iapValidator.ValidatePurchaseForDeck(verifyReq, h.cfg.FreeDecks)
		if err != nil {
			writeError(w, http.StatusPaymentRequired, err.Error())
			return
		}

		if !result.Valid {
			writeError(w, http.StatusForbidden, result.Error)
			return
		}
	}

	// Return the deck
	deck, err := h.generator.GetDeck(deckID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, deck)
}

func (h *Handlers) VerifyReceipt(w http.ResponseWriter, r *http.Request) {
	var req iap.VerifyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Platform == "" || req.ReceiptData == "" {
		writeError(w, http.StatusBadRequest, "platform and receiptData required")
		return
	}

	result, err := h.iapValidator.Verify(req)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, result)
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}
