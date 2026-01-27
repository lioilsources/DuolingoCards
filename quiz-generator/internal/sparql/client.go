package sparql

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

const WikidataEndpoint = "https://query.wikidata.org/sparql"

// Client is a SPARQL query client for Wikidata.
type Client struct {
	httpClient *http.Client
	userAgent  string
}

// NewClient creates a new SPARQL client.
func NewClient() *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		userAgent: "DuolingoCards-QuizGenerator/1.0 (https://github.com/duolingocards)",
	}
}

// QueryResult represents the JSON response from Wikidata.
type QueryResult struct {
	Results struct {
		Bindings []map[string]struct {
			Type  string `json:"type"`
			Value string `json:"value"`
		} `json:"bindings"`
	} `json:"results"`
}

// Query executes a SPARQL query and returns the result.
func (c *Client) Query(sparql string) (*QueryResult, error) {
	reqURL := fmt.Sprintf("%s?query=%s&format=json", WikidataEndpoint, url.QueryEscape(sparql))

	req, err := http.NewRequest("GET", reqURL, nil)
	if err != nil {
		return nil, fmt.Errorf("creating request: %w", err)
	}

	req.Header.Set("User-Agent", c.userAgent)
	req.Header.Set("Accept", "application/sparql-results+json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("executing request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("wikidata returned %d: %s", resp.StatusCode, string(body))
	}

	var result QueryResult
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding response: %w", err)
	}

	return &result, nil
}

// GetValue extracts a string value from a binding, returning empty string if not found.
func GetValue(binding map[string]struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}, key string) string {
	if v, ok := binding[key]; ok {
		return v.Value
	}
	return ""
}
