package api

import (
	"net/http"

	"github.com/example/duolingocards-backend/internal/config"
)

func SetupRoutes(mux *http.ServeMux, handlers *Handlers, cfg *config.Config) {
	// API routes
	mux.HandleFunc("GET /api/catalog", handlers.GetCatalog)
	mux.HandleFunc("GET /api/decks/{id}/preview", handlers.GetDeckPreview)
	mux.HandleFunc("GET /api/decks/{id}", handlers.GetDeck)
	mux.HandleFunc("POST /api/decks/{id}/generate", handlers.GenerateDeck)
	mux.HandleFunc("GET /api/decks/{id}/status", handlers.GetGenerateStatus)
	mux.HandleFunc("POST /api/decks/{id}/download", handlers.DownloadDeck)

	// IAP receipt verification
	mux.HandleFunc("POST /api/receipts/verify", handlers.VerifyReceipt)

	// Serve static media files
	fs := http.FileServer(http.Dir(cfg.StoragePath))
	mux.Handle("/media/", http.StripPrefix("/media/", fs))
}
