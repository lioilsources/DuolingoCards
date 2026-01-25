package image

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const (
	// Gemini API endpoint for image generation
	geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict"
)

type ImagenClient struct {
	apiKey string
	client *http.Client
}

func NewImagenClient(apiKey string) *ImagenClient {
	return &ImagenClient{
		apiKey: apiKey,
		client: &http.Client{},
	}
}

type imagenRequest struct {
	Instances  []imagenInstance `json:"instances"`
	Parameters imagenParams     `json:"parameters"`
}

type imagenInstance struct {
	Prompt string `json:"prompt"`
}

type imagenParams struct {
	SampleCount       int    `json:"sampleCount"`
	AspectRatio       string `json:"aspectRatio"`
	PersonGeneration  string `json:"personGeneration"`
}

type imagenResponse struct {
	Predictions []struct {
		BytesBase64Encoded string `json:"bytesBase64Encoded"`
		MimeType           string `json:"mimeType"`
	} `json:"predictions"`
}

// GenerateImage generates an image from a prompt
func (c *ImagenClient) GenerateImage(prompt string) ([]byte, error) {
	url := fmt.Sprintf("%s?key=%s", geminiBaseURL, c.apiKey)

	reqBody := imagenRequest{
		Instances: []imagenInstance{
			{Prompt: prompt},
		},
		Parameters: imagenParams{
			SampleCount:      1,
			AspectRatio:      "1:1",
			PersonGeneration: "dont_allow",
		},
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequest("POST", url, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error (status %d): %s", resp.StatusCode, string(body))
	}

	var result imagenResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	if len(result.Predictions) == 0 {
		return nil, fmt.Errorf("no image generated")
	}

	// Decode base64 image
	imageData, err := base64.StdEncoding.DecodeString(result.Predictions[0].BytesBase64Encoded)
	if err != nil {
		return nil, fmt.Errorf("failed to decode image: %w", err)
	}

	return imageData, nil
}
