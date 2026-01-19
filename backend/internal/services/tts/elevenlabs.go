package tts

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const (
	elevenLabsBaseURL = "https://api.elevenlabs.io/v1"
	// Japanese voice - you can change this to other voice IDs
	defaultVoiceID = "21m00Tcm4TlvDq8ikWAM" // Rachel - works well for multiple languages
)

type ElevenLabsClient struct {
	apiKey  string
	voiceID string
	client  *http.Client
}

func NewElevenLabsClient(apiKey string) *ElevenLabsClient {
	return &ElevenLabsClient{
		apiKey:  apiKey,
		voiceID: defaultVoiceID,
		client:  &http.Client{},
	}
}

func (c *ElevenLabsClient) SetVoiceID(voiceID string) {
	c.voiceID = voiceID
}

type ttsRequest struct {
	Text          string        `json:"text"`
	ModelID       string        `json:"model_id"`
	VoiceSettings voiceSettings `json:"voice_settings"`
}

type voiceSettings struct {
	Stability       float64 `json:"stability"`
	SimilarityBoost float64 `json:"similarity_boost"`
}

func (c *ElevenLabsClient) GenerateSpeech(text string) ([]byte, error) {
	url := fmt.Sprintf("%s/text-to-speech/%s", elevenLabsBaseURL, c.voiceID)

	reqBody := ttsRequest{
		Text:    text,
		ModelID: "eleven_multilingual_v2", // Supports Japanese
		VoiceSettings: voiceSettings{
			Stability:       0.5,
			SimilarityBoost: 0.75,
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
	req.Header.Set("xi-api-key", c.apiKey)
	req.Header.Set("Accept", "audio/mpeg")

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error (status %d): %s", resp.StatusCode, string(body))
	}

	return io.ReadAll(resp.Body)
}
