package storage

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
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
