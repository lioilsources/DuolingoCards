package pokemon

import (
	"fmt"
	"path/filepath"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/media"
)

// Generator generates Pokemon quiz items from PokéAPI.
type Generator struct {
	client     *Client
	downloader *media.Downloader
}

// New creates a new Pokemon generator.
func New() *Generator {
	return &Generator{
		client:     NewClient(),
		downloader: media.NewDownloader(),
	}
}

// Name returns the generator name.
func (g *Generator) Name() string {
	return "pokemon"
}

// FetchData fetches Pokemon data from PokéAPI.
// opts.Limit controls how many Pokemon to fetch (default 151 for Gen 1).
func (g *Generator) FetchData(opts generator.Options) ([]generator.QuizItem, error) {
	limit := opts.Limit
	if limit <= 0 {
		limit = 151
	}

	fmt.Printf("Fetching %d Pokémon from PokéAPI...\n", limit)

	var items []generator.QuizItem

	for id := 1; id <= limit; id++ {
		fmt.Printf("  [%d/%d] Fetching #%d...", id, limit, id)

		pokemonData, err := g.client.FetchPokemon(id)
		if err != nil {
			fmt.Printf(" FAILED: %v\n", err)
			continue
		}

		fmt.Printf(" %s (%s)\n", pokemonData.Name, pokemonData.NameJA)

		item := buildQuizItem(pokemonData)
		items = append(items, item)
	}

	fmt.Printf("Fetched %d Pokémon\n", len(items))
	return items, nil
}

// DownloadMedia downloads official artwork PNGs for all items.
func (g *Generator) DownloadMedia(items []generator.QuizItem, outputDir string) ([]generator.QuizItem, error) {
	fmt.Printf("Downloading %d Pokémon artwork images...\n", len(items))

	updated := make([]generator.QuizItem, len(items))
	copy(updated, items)

	for i, item := range updated {
		if item.ImageURL == "" {
			fmt.Printf("  [%d/%d] %s: no artwork URL\n", i+1, len(items), item.ID)
			continue
		}

		fmt.Printf("  [%d/%d] %s: downloading artwork...\n", i+1, len(items), item.ID)

		destPath := filepath.Join(outputDir, item.ID+".png")
		if err := g.downloader.DownloadFile(item.ImageURL, destPath); err != nil {
			fmt.Printf("    Warning: failed to download %s: %v\n", item.ID, err)
			continue
		}

		updated[i].LocalImage = "images/" + item.ID + ".png"

		time.Sleep(200 * time.Millisecond)
	}

	return updated, nil
}

func buildQuizItem(data *PokemonData) generator.QuizItem {
	// Czech type names
	typeStrs := make([]string, len(data.Types))
	for i, t := range data.Types {
		if czType, ok := CzechTypeNames[t]; ok {
			typeStrs[i] = czType
		} else {
			typeStrs[i] = capitalizeFirst(t)
		}
	}

	heightStr := fmt.Sprintf("%.1f m", float64(data.Height)/10.0)
	weightStr := fmt.Sprintf("%.1f kg", float64(data.Weight)/10.0)

	fields := []generator.Field{
		{Label: "Typ", Value: strings.Join(typeStrs, ", ")},
		{Label: "HP", Value: fmt.Sprintf("%d", data.Stats.HP)},
		{Label: "Útok", Value: fmt.Sprintf("%d", data.Stats.Attack)},
		{Label: "Obrana", Value: fmt.Sprintf("%d", data.Stats.Defense)},
		{Label: "Sp. útok", Value: fmt.Sprintf("%d", data.Stats.SpAtk)},
		{Label: "Sp. obrana", Value: fmt.Sprintf("%d", data.Stats.SpDef)},
		{Label: "Rychlost", Value: fmt.Sprintf("%d", data.Stats.Speed)},
		{Label: "Generace", Value: data.Generation},
		{Label: "Výška", Value: heightStr},
		{Label: "Váha", Value: weightStr},
	}

	return generator.QuizItem{
		ID:       createSlug(data.Name),
		Title:    data.Name,
		Subtitle: data.NameJA,
		ImageURL: data.ArtworkURL,
		Fields:   fields,
	}
}

func createSlug(name string) string {
	slug := strings.ToLower(name)
	slug = strings.Map(func(r rune) rune {
		switch {
		case r >= 'a' && r <= 'z':
			return r
		case r >= '0' && r <= '9':
			return r
		case r == ' ' || r == '-' || r == '_':
			return '-'
		case r == '♀':
			return 'f'
		case r == '♂':
			return 'm'
		default:
			return -1
		}
	}, slug)

	for strings.Contains(slug, "--") {
		slug = strings.ReplaceAll(slug, "--", "-")
	}
	return strings.Trim(slug, "-")
}
