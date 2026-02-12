package pokemon

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const (
	baseURL    = "https://pokeapi.co/api/v2"
	artworkURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/%d.png"
	rateDelay  = 100 * time.Millisecond
)

// Client is a PokéAPI client with built-in rate limiting.
type Client struct {
	httpClient *http.Client
	userAgent  string
}

// NewClient creates a new PokéAPI client.
func NewClient() *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		userAgent: "DuolingoCards-QuizGenerator/1.0",
	}
}

// pokemonResponse represents GET /pokemon/{id} JSON.
type pokemonResponse struct {
	ID     int    `json:"id"`
	Name   string `json:"name"`
	Height int    `json:"height"`
	Weight int    `json:"weight"`
	Types  []struct {
		Type struct {
			Name string `json:"name"`
		} `json:"type"`
	} `json:"types"`
	Stats []struct {
		BaseStat int `json:"base_stat"`
		Stat     struct {
			Name string `json:"name"`
		} `json:"stat"`
	} `json:"stats"`
}

// speciesResponse represents GET /pokemon-species/{id} JSON.
type speciesResponse struct {
	Names []struct {
		Name     string `json:"name"`
		Language struct {
			Name string `json:"name"`
		} `json:"language"`
	} `json:"names"`
	Generation struct {
		Name string `json:"name"`
	} `json:"generation"`
}

// FetchPokemon fetches combined data for a single Pokemon by ID.
func (c *Client) FetchPokemon(id int) (*PokemonData, error) {
	// Fetch /pokemon/{id}
	pData, err := c.fetchPokemon(id)
	if err != nil {
		return nil, fmt.Errorf("fetching pokemon %d: %w", id, err)
	}

	time.Sleep(rateDelay)

	// Fetch /pokemon-species/{id}
	sData, err := c.fetchSpecies(id)
	if err != nil {
		return nil, fmt.Errorf("fetching species %d: %w", id, err)
	}

	time.Sleep(rateDelay)

	return combinePokemonData(id, pData, sData), nil
}

func (c *Client) fetchPokemon(id int) (*pokemonResponse, error) {
	body, err := c.get(fmt.Sprintf("%s/pokemon/%d", baseURL, id))
	if err != nil {
		return nil, err
	}
	var resp pokemonResponse
	if err := json.Unmarshal(body, &resp); err != nil {
		return nil, fmt.Errorf("parsing pokemon JSON: %w", err)
	}
	return &resp, nil
}

func (c *Client) fetchSpecies(id int) (*speciesResponse, error) {
	body, err := c.get(fmt.Sprintf("%s/pokemon-species/%d", baseURL, id))
	if err != nil {
		return nil, err
	}
	var resp speciesResponse
	if err := json.Unmarshal(body, &resp); err != nil {
		return nil, fmt.Errorf("parsing species JSON: %w", err)
	}
	return &resp, nil
}

func (c *Client) get(url string) ([]byte, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", c.userAgent)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned %d for %s", resp.StatusCode, url)
	}

	return io.ReadAll(resp.Body)
}

func combinePokemonData(id int, p *pokemonResponse, s *speciesResponse) *PokemonData {
	data := &PokemonData{
		ID:         id,
		Name:       capitalizeFirst(p.Name),
		Height:     p.Height,
		Weight:     p.Weight,
		ArtworkURL: fmt.Sprintf(artworkURL, id),
	}

	// Types
	for _, t := range p.Types {
		data.Types = append(data.Types, t.Type.Name)
	}

	// Stats
	for _, s := range p.Stats {
		switch s.Stat.Name {
		case "hp":
			data.Stats.HP = s.BaseStat
		case "attack":
			data.Stats.Attack = s.BaseStat
		case "defense":
			data.Stats.Defense = s.BaseStat
		case "special-attack":
			data.Stats.SpAtk = s.BaseStat
		case "special-defense":
			data.Stats.SpDef = s.BaseStat
		case "speed":
			data.Stats.Speed = s.BaseStat
		}
	}

	// Japanese name from species
	for _, n := range s.Names {
		if n.Language.Name == "ja" {
			data.NameJA = n.Name
		}
	}

	// Generation
	if gen, ok := GenerationMap[s.Generation.Name]; ok {
		data.Generation = gen
	}

	return data
}

func capitalizeFirst(s string) string {
	if s == "" {
		return s
	}
	return strings.ToUpper(s[:1]) + s[1:]
}
