package config

import (
	"os"
)

type Config struct {
	Port            string
	ElevenLabsKey   string
	GoogleAPIKey    string
	StoragePath     string
	StorageBaseURL  string

	// IAP validation
	AppleSharedSecret string
	GooglePackageName string
	IAPSandboxMode    bool
	FreeDecks         []string
}

func Load() *Config {
	return &Config{
		Port:            getEnv("PORT", "8080"),
		ElevenLabsKey:   getEnv("ELEVENLABS_API_KEY", ""),
		GoogleAPIKey:    getEnv("GOOGLE_API_KEY", ""),
		StoragePath:     getEnv("STORAGE_PATH", "./media"),
		StorageBaseURL:  getEnv("STORAGE_BASE_URL", "http://localhost:8080/media"),

		// IAP
		AppleSharedSecret: getEnv("APPLE_SHARED_SECRET", ""),
		GooglePackageName: getEnv("GOOGLE_PACKAGE_NAME", "com.example.duolingocards"),
		IAPSandboxMode:    getEnv("IAP_SANDBOX_MODE", "true") == "true",
		FreeDecks:         []string{"japanese-basics"}, // Default free deck
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
