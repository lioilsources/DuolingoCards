package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/example/duolingocards-backend/internal/api"
	"github.com/example/duolingocards-backend/internal/config"
	"github.com/example/duolingocards-backend/internal/services"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Printf("Note: .env file not found, using environment variables")
	}

	cfg := config.Load()

	generator := services.NewGenerator(cfg)
	handlers := api.NewHandlers(generator, cfg)

	mux := http.NewServeMux()
	api.SetupRoutes(mux, handlers, cfg)

	// Add CORS middleware for development
	handler := corsMiddleware(mux)

	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Starting server on %s", addr)
	log.Printf("Storage path: %s", cfg.StoragePath)
	log.Printf("Storage base URL: %s", cfg.StorageBaseURL)

	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatal(err)
	}
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
