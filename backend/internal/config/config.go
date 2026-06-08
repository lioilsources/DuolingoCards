package config

import (
	"os"
	"time"
)

type Config struct {
	Port           string
	ElevenLabsKey  string
	GoogleAPIKey   string
	StoragePath    string
	StorageBaseURL string

	// Image generation backend: "imagen" (default) or "comfyui"
	ImageBackend        string
	ComfyUIURL          string
	CFAccessClientID    string
	CFAccessClientSecret string
	ComfyJobTimeout     time.Duration

	// IAP validation
	AppleSharedSecret string
	GooglePackageName string
	IAPSandboxMode    bool
	FreeDecks         []string
}

func Load() *Config {
	return &Config{
		Port:           getEnv("PORT", "8080"),
		ElevenLabsKey:  getEnv("ELEVENLABS_API_KEY", ""),
		GoogleAPIKey:   getEnv("GOOGLE_API_KEY", ""),
		StoragePath:    getEnv("STORAGE_PATH", "./media"),
		StorageBaseURL: getEnv("STORAGE_BASE_URL", "http://localhost:8080/media"),

		// Image backend
		ImageBackend:         getEnv("IMAGE_BACKEND", "imagen"),
		ComfyUIURL:           getEnv("COMFYUI_API_URL", ""),
		CFAccessClientID:     getEnv("CF_ACCESS_CLIENT_ID", ""),
		CFAccessClientSecret: getEnv("CF_ACCESS_CLIENT_SECRET", ""),
		ComfyJobTimeout:      getEnvDuration("COMFYUI_JOB_TIMEOUT", 15*time.Minute),

		// IAP
		AppleSharedSecret: getEnv("APPLE_SHARED_SECRET", ""),
		GooglePackageName: getEnv("GOOGLE_PACKAGE_NAME", "com.example.duolingocards"),
		IAPSandboxMode:    getEnv("IAP_SANDBOX_MODE", "true") == "true",
		FreeDecks:         []string{"japanese-basics"},
	}
}

func getEnvDuration(key string, defaultValue time.Duration) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return defaultValue
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return defaultValue
	}
	return d
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
