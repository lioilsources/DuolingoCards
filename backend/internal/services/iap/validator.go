package iap

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// Validator handles IAP receipt validation for Apple and Google
type Validator struct {
	appleSharedSecret string
	googlePackageName string
	useSandbox        bool
}

// NewValidator creates a new IAP validator
func NewValidator(appleSecret, googlePackage string, useSandbox bool) *Validator {
	return &Validator{
		appleSharedSecret: appleSecret,
		googlePackageName: googlePackage,
		useSandbox:        useSandbox,
	}
}

// VerifyRequest represents a receipt verification request
type VerifyRequest struct {
	Platform    string `json:"platform"`    // "ios" or "android"
	ReceiptData string `json:"receiptData"` // Base64 receipt (iOS) or purchase token (Android)
	ProductID   string `json:"productId"`   // Expected product ID
	DeckID      string `json:"deckId"`      // Deck being purchased
}

// VerifyResponse represents the verification result
type VerifyResponse struct {
	Valid     bool   `json:"valid"`
	DeckID    string `json:"deckId,omitempty"`
	ProductID string `json:"productId,omitempty"`
	Error     string `json:"error,omitempty"`
}

// Verify validates an IAP receipt
func (v *Validator) Verify(req VerifyRequest) (*VerifyResponse, error) {
	switch strings.ToLower(req.Platform) {
	case "ios":
		return v.verifyApple(req)
	case "android":
		return v.verifyGoogle(req)
	default:
		return &VerifyResponse{Valid: false, Error: "unknown platform"}, nil
	}
}

// Apple App Store receipt validation

const (
	appleProductionURL = "https://buy.itunes.apple.com/verifyReceipt"
	appleSandboxURL    = "https://sandbox.itunes.apple.com/verifyReceipt"
)

type appleReceiptRequest struct {
	ReceiptData            string `json:"receipt-data"`
	Password               string `json:"password,omitempty"`
	ExcludeOldTransactions bool   `json:"exclude-old-transactions"`
}

type appleReceiptResponse struct {
	Status      int                    `json:"status"`
	Environment string                 `json:"environment"`
	Receipt     map[string]interface{} `json:"receipt"`
	LatestReceipt string               `json:"latest_receipt,omitempty"`
}

func (v *Validator) verifyApple(req VerifyRequest) (*VerifyResponse, error) {
	// Prepare request
	appleReq := appleReceiptRequest{
		ReceiptData:            req.ReceiptData,
		Password:               v.appleSharedSecret,
		ExcludeOldTransactions: true,
	}

	body, err := json.Marshal(appleReq)
	if err != nil {
		return nil, fmt.Errorf("marshal apple request: %w", err)
	}

	// Try production first, then sandbox if needed
	url := appleProductionURL
	if v.useSandbox {
		url = appleSandboxURL
	}

	resp, err := v.sendAppleRequest(url, body)
	if err != nil {
		return nil, err
	}

	// Status 21007 means receipt is from sandbox, retry with sandbox URL
	if resp.Status == 21007 && !v.useSandbox {
		resp, err = v.sendAppleRequest(appleSandboxURL, body)
		if err != nil {
			return nil, err
		}
	}

	// Check status
	if resp.Status != 0 {
		return &VerifyResponse{
			Valid: false,
			Error: fmt.Sprintf("apple verification failed: status %d", resp.Status),
		}, nil
	}

	// Extract in-app purchases from receipt
	inApp, ok := resp.Receipt["in_app"].([]interface{})
	if !ok || len(inApp) == 0 {
		return &VerifyResponse{
			Valid: false,
			Error: "no in-app purchases in receipt",
		}, nil
	}

	// Check if the expected product is in the receipt
	for _, item := range inApp {
		purchase, ok := item.(map[string]interface{})
		if !ok {
			continue
		}

		productID, _ := purchase["product_id"].(string)
		if productID == req.ProductID {
			return &VerifyResponse{
				Valid:     true,
				DeckID:    req.DeckID,
				ProductID: productID,
			}, nil
		}
	}

	return &VerifyResponse{
		Valid: false,
		Error: "product not found in receipt",
	}, nil
}

func (v *Validator) sendAppleRequest(url string, body []byte) (*appleReceiptResponse, error) {
	httpResp, err := http.Post(url, "application/json", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("apple request failed: %w", err)
	}
	defer httpResp.Body.Close()

	respBody, err := io.ReadAll(httpResp.Body)
	if err != nil {
		return nil, fmt.Errorf("read apple response: %w", err)
	}

	var appleResp appleReceiptResponse
	if err := json.Unmarshal(respBody, &appleResp); err != nil {
		return nil, fmt.Errorf("unmarshal apple response: %w", err)
	}

	return &appleResp, nil
}

// Google Play receipt validation
// Note: For production, you should use the Google Play Developer API with service account

func (v *Validator) verifyGoogle(req VerifyRequest) (*VerifyResponse, error) {
	// In development/sandbox mode, accept any receipt
	if v.useSandbox {
		return &VerifyResponse{
			Valid:     true,
			DeckID:    req.DeckID,
			ProductID: req.ProductID,
		}, nil
	}

	// For production, implement Google Play Developer API validation
	// This requires:
	// 1. Service account credentials
	// 2. OAuth2 token
	// 3. Call to purchases.products.get endpoint

	// Placeholder - in production, implement proper validation
	if req.ReceiptData == "" {
		return &VerifyResponse{
			Valid: false,
			Error: "empty receipt data",
		}, nil
	}

	// Parse the purchase token (simplified)
	// Real implementation should verify with Google API
	return &VerifyResponse{
		Valid:     true,
		DeckID:    req.DeckID,
		ProductID: req.ProductID,
	}, nil
}

// IsPaidDeck checks if a deck requires purchase
func IsPaidDeck(deckID string, freeDecks []string) bool {
	for _, free := range freeDecks {
		if free == deckID {
			return false
		}
	}
	return true
}

// ValidatePurchaseForDeck validates that a receipt grants access to a specific deck
func (v *Validator) ValidatePurchaseForDeck(req VerifyRequest, freeDecks []string) (*VerifyResponse, error) {
	// Free decks don't require validation
	if !IsPaidDeck(req.DeckID, freeDecks) {
		return &VerifyResponse{
			Valid:  true,
			DeckID: req.DeckID,
		}, nil
	}

	// Validate the receipt
	if req.ReceiptData == "" {
		return nil, errors.New("receipt required for paid deck")
	}

	return v.Verify(req)
}
