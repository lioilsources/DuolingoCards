package overpass

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const Endpoint = "https://overpass-api.de/api/interpreter"

// Client is an Overpass API client for OpenStreetMap queries.
type Client struct {
	httpClient *http.Client
	userAgent  string
}

// NewClient creates a new Overpass API client.
func NewClient() *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: 60 * time.Second,
		},
		userAgent: "DuolingoCards-QuizGenerator/1.0 (https://github.com/duolingocards)",
	}
}

// Element represents a single OSM element (node, way, or relation).
type Element struct {
	Type   string            `json:"type"`
	ID     int64             `json:"id"`
	Tags   map[string]string `json:"tags,omitempty"`
	Center *LatLon           `json:"center,omitempty"`
	Bounds *Bounds           `json:"bounds,omitempty"`
	Nodes  []int64           `json:"nodes,omitempty"`
	Geometry []LatLon        `json:"geometry,omitempty"`
	Members []Member         `json:"members,omitempty"`
}

// LatLon represents a geographic coordinate.
type LatLon struct {
	Lat float64 `json:"lat"`
	Lon float64 `json:"lon"`
}

// Bounds represents a bounding box.
type Bounds struct {
	MinLat float64 `json:"minlat"`
	MinLon float64 `json:"minlon"`
	MaxLat float64 `json:"maxlat"`
	MaxLon float64 `json:"maxlon"`
}

// Member represents a relation member.
type Member struct {
	Type     string   `json:"type"`
	Ref      int64    `json:"ref"`
	Role     string   `json:"role"`
	Geometry []LatLon `json:"geometry,omitempty"`
}

// QueryResult represents the JSON response from Overpass API.
type QueryResult struct {
	Version   float64   `json:"version"`
	Generator string    `json:"generator"`
	Elements  []Element `json:"elements"`
}

// Query executes an Overpass QL query and returns the result.
func (c *Client) Query(overpassQL string) (*QueryResult, error) {
	req, err := http.NewRequest("POST", Endpoint, strings.NewReader("data="+overpassQL))
	if err != nil {
		return nil, fmt.Errorf("creating request: %w", err)
	}

	req.Header.Set("User-Agent", c.userAgent)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("executing request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("overpass returned %d: %s", resp.StatusCode, string(body))
	}

	var result QueryResult
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding response: %w", err)
	}

	return &result, nil
}

// GetTag safely retrieves a tag value from an element.
func GetTag(elem Element, key string) string {
	if elem.Tags == nil {
		return ""
	}
	return elem.Tags[key]
}

// GetBounds returns the bounding box for an element.
// For relations with bounds, returns the bounds directly.
// For elements with geometry, computes bounds from coordinates.
func GetBounds(elem Element) *Bounds {
	if elem.Bounds != nil {
		return elem.Bounds
	}

	// Compute from geometry
	coords := elem.Geometry
	if len(coords) == 0 {
		// Try to get coordinates from members
		for _, m := range elem.Members {
			coords = append(coords, m.Geometry...)
		}
	}

	if len(coords) == 0 {
		return nil
	}

	bounds := &Bounds{
		MinLat: coords[0].Lat,
		MaxLat: coords[0].Lat,
		MinLon: coords[0].Lon,
		MaxLon: coords[0].Lon,
	}

	for _, c := range coords {
		if c.Lat < bounds.MinLat {
			bounds.MinLat = c.Lat
		}
		if c.Lat > bounds.MaxLat {
			bounds.MaxLat = c.Lat
		}
		if c.Lon < bounds.MinLon {
			bounds.MinLon = c.Lon
		}
		if c.Lon > bounds.MaxLon {
			bounds.MaxLon = c.Lon
		}
	}

	return bounds
}
