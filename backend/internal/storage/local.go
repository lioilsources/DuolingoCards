package storage

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"unicode"

	"golang.org/x/text/runes"
	"golang.org/x/text/transform"
	"golang.org/x/text/unicode/norm"
)

type LocalStorage struct {
	basePath string
	baseURL  string
}

func NewLocalStorage(basePath, baseURL string) *LocalStorage {
	return &LocalStorage{
		basePath: basePath,
		baseURL:  baseURL,
	}
}

// SaveFlat saves a file in flat structure: {deckID}/{filename}
// filename should already include the full name like "01-hello-image.png"
func (s *LocalStorage) SaveFlat(deckID, filename string, data []byte) (string, error) {
	dir := filepath.Join(s.basePath, deckID)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", fmt.Errorf("failed to create directory: %w", err)
	}

	path := filepath.Join(dir, filename)
	if err := os.WriteFile(path, data, 0644); err != nil {
		return "", fmt.Errorf("failed to write file: %w", err)
	}

	url := fmt.Sprintf("%s/%s/%s", s.baseURL, deckID, filename)
	return url, nil
}

// BuildMediaFilename creates a filename like "01-hello-image.png" or "01-konnichiwa-audio.mp3"
func BuildMediaFilename(index int, name string, mediaType string, extension string) string {
	slug := Slugify(name)
	return fmt.Sprintf("%02d-%s-%s.%s", index, slug, mediaType, extension)
}

// Slugify converts a string to a URL-safe slug
// "Dobrý den" -> "dobry-den"
// "konnichiwa" -> "konnichiwa"
func Slugify(s string) string {
	// Normalize unicode and remove diacritics
	t := transform.Chain(norm.NFD, runes.Remove(runes.In(unicode.Mn)), norm.NFC)
	result, _, _ := transform.String(t, s)

	// Convert to lowercase
	result = strings.ToLower(result)

	// Replace spaces and non-alphanumeric with hyphens
	reg := regexp.MustCompile(`[^a-z0-9]+`)
	result = reg.ReplaceAllString(result, "-")

	// Trim leading/trailing hyphens
	result = strings.Trim(result, "-")

	// Limit length
	if len(result) > 30 {
		result = result[:30]
		// Don't end with hyphen
		result = strings.TrimRight(result, "-")
	}

	return result
}

// Legacy methods for backwards compatibility

func (s *LocalStorage) Save(deckID, cardID, filename string, data []byte) (string, error) {
	dir := filepath.Join(s.basePath, deckID, cardID)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", fmt.Errorf("failed to create directory: %w", err)
	}

	path := filepath.Join(dir, filename)
	if err := os.WriteFile(path, data, 0644); err != nil {
		return "", fmt.Errorf("failed to write file: %w", err)
	}

	url := fmt.Sprintf("%s/%s/%s/%s", s.baseURL, deckID, cardID, filename)
	return url, nil
}

func (s *LocalStorage) SaveReader(deckID, cardID, filename string, reader io.Reader) (string, error) {
	dir := filepath.Join(s.basePath, deckID, cardID)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", fmt.Errorf("failed to create directory: %w", err)
	}

	path := filepath.Join(dir, filename)
	file, err := os.Create(path)
	if err != nil {
		return "", fmt.Errorf("failed to create file: %w", err)
	}
	defer file.Close()

	if _, err := io.Copy(file, reader); err != nil {
		return "", fmt.Errorf("failed to write file: %w", err)
	}

	url := fmt.Sprintf("%s/%s/%s/%s", s.baseURL, deckID, cardID, filename)
	return url, nil
}

func (s *LocalStorage) Delete(deckID, cardID string) error {
	dir := filepath.Join(s.basePath, deckID, cardID)
	return os.RemoveAll(dir)
}

func (s *LocalStorage) Exists(deckID, cardID, filename string) bool {
	path := filepath.Join(s.basePath, deckID, cardID, filename)
	_, err := os.Stat(path)
	return err == nil
}

// ExistsFlat checks if a flat file exists
func (s *LocalStorage) ExistsFlat(deckID, filename string) bool {
	path := filepath.Join(s.basePath, deckID, filename)
	_, err := os.Stat(path)
	return err == nil
}

// BuildURL constructs a URL for an existing file without saving
func (s *LocalStorage) BuildURL(deckID, filename string) string {
	return fmt.Sprintf("%s/%s/%s", s.baseURL, deckID, filename)
}
