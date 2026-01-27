package capitals

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/media"
	"github.com/duolingocards/quiz-generator/internal/sparql"
)

// Generator generates quiz items for world capitals.
type Generator struct {
	sparqlClient *sparql.Client
	downloader   *media.Downloader
}

// New creates a new capitals generator.
func New() *Generator {
	return &Generator{
		sparqlClient: sparql.NewClient(),
		downloader:   media.NewDownloader(),
	}
}

// Name returns the generator name.
func (g *Generator) Name() string {
	return "capitals"
}

// FetchData fetches capital city data from Wikidata.
func (g *Generator) FetchData(opts generator.Options) ([]generator.QuizItem, error) {
	query := BuildQuery(opts.Language, opts.Limit)

	fmt.Printf("Fetching data from Wikidata (limit: %d, language: %s)...\n", opts.Limit, opts.Language)

	result, err := g.sparqlClient.Query(query)
	if err != nil {
		return nil, fmt.Errorf("SPARQL query failed: %w", err)
	}

	var items []generator.QuizItem
	seen := make(map[string]bool)

	for _, binding := range result.Results.Bindings {
		countryCode := strings.ToLower(sparql.GetValue(binding, "countryCode"))
		if countryCode == "" || seen[countryCode] {
			continue
		}
		seen[countryCode] = true

		countryLabel := sparql.GetValue(binding, "countryLabel")
		capitalLabel := sparql.GetValue(binding, "capitalLabel")
		countryPopStr := sparql.GetValue(binding, "countryPopulation")
		capitalPopStr := sparql.GetValue(binding, "capitalPopulation")

		// Use flagcdn.com PNG instead of Wikimedia SVG (avoids conversion)
		flagURL := fmt.Sprintf("https://flagcdn.com/w640/%s.png", countryCode)

		// Extract Wikidata ID from country URI
		countryURI := sparql.GetValue(binding, "country")
		wikidataID := ""
		if idx := strings.LastIndex(countryURI, "/"); idx != -1 {
			wikidataID = countryURI[idx+1:]
		}

		// Format populations
		countryPop := formatPopulation(countryPopStr)
		capitalPop := formatPopulation(capitalPopStr)

		fields := []generator.Field{
			{Label: "Populace státu", Value: countryPop},
		}
		if capitalPop != "N/A" {
			fields = append(fields, generator.Field{Label: "Populace hl. města", Value: capitalPop})
		}

		item := generator.QuizItem{
			ID:         countryCode,
			Title:      countryLabel,
			Subtitle:   capitalLabel,
			ImageURL:   flagURL,
			Fields:     fields,
			WikidataID: wikidataID,
		}

		items = append(items, item)
	}

	fmt.Printf("Found %d countries with capitals\n", len(items))
	return items, nil
}

// DownloadMedia downloads flag images for all items.
func (g *Generator) DownloadMedia(items []generator.QuizItem, outputDir string) ([]generator.QuizItem, error) {
	fmt.Printf("Downloading %d flag images...\n", len(items))

	updated := make([]generator.QuizItem, len(items))
	copy(updated, items)

	for i, item := range updated {
		if item.ImageURL == "" {
			fmt.Printf("  [%d/%d] %s: no flag URL\n", i+1, len(items), item.ID)
			continue
		}

		fmt.Printf("  [%d/%d] %s: downloading flag...\n", i+1, len(items), item.ID)

		localFile, err := g.downloader.DownloadAndConvert(item.ImageURL, outputDir, item.ID, 512)
		if err != nil {
			fmt.Printf("    Warning: failed to download %s: %v\n", item.ID, err)
			continue
		}

		updated[i].LocalImage = "flags/" + localFile

		// Be nice to Wikimedia servers
		time.Sleep(200 * time.Millisecond)
	}

	return updated, nil
}

// formatPopulation formats a population number string to a human-readable format.
func formatPopulation(popStr string) string {
	if popStr == "" {
		return "N/A"
	}

	pop, err := strconv.ParseFloat(popStr, 64)
	if err != nil {
		return popStr
	}

	if pop >= 1_000_000_000 {
		return fmt.Sprintf("%.1f mld", pop/1_000_000_000)
	} else if pop >= 1_000_000 {
		return fmt.Sprintf("%.1f mil", pop/1_000_000)
	} else if pop >= 1_000 {
		return fmt.Sprintf("%.0f tis", pop/1_000)
	}

	return fmt.Sprintf("%.0f", pop)
}
