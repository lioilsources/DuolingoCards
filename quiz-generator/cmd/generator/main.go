package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/duolingocards/quiz-generator/internal/capitals"
	"github.com/duolingocards/quiz-generator/internal/deck"
	"github.com/duolingocards/quiz-generator/internal/generator"
)

func main() {
	// CLI flags
	genType := flag.String("type", "capitals", "Type of quiz to generate (capitals, mountains, rivers)")
	limit := flag.Int("limit", 50, "Maximum number of items to fetch")
	lang := flag.String("lang", "cs", "Language code for labels (cs, en, de, etc.)")
	outputDir := flag.String("output", "output", "Output directory for generated files")
	flag.Parse()

	opts := generator.Options{
		Limit:    *limit,
		Language: *lang,
	}

	switch *genType {
	case "capitals":
		if err := generateCapitals(opts, *outputDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	default:
		fmt.Fprintf(os.Stderr, "Unknown generator type: %s\n", *genType)
		fmt.Fprintf(os.Stderr, "Available types: capitals\n")
		os.Exit(1)
	}
}

func generateCapitals(opts generator.Options, outputDir string) error {
	gen := capitals.New()

	fmt.Println("=== World Capitals Quiz Generator ===")
	fmt.Printf("Language: %s, Limit: %d\n\n", opts.Language, opts.Limit)

	// Fetch data from Wikidata
	items, err := gen.FetchData(opts)
	if err != nil {
		return fmt.Errorf("fetching data: %w", err)
	}

	if len(items) == 0 {
		return fmt.Errorf("no data returned from Wikidata")
	}

	// Download media (flags)
	mediaDir := filepath.Join(outputDir, "media", "flags")
	items, err = gen.DownloadMedia(items, mediaDir)
	if err != nil {
		return fmt.Errorf("downloading media: %w", err)
	}

	// Build deck
	builder := deck.NewBuilder(
		"world-capitals-50",
		"Hlavní města světa",
		"Top 50 států dle populace s jejich hlavními městy a vlajkami",
		opts.Language,
		"assets/media/world-capitals-50",
	)

	for _, item := range items {
		builder.AddCard(item, "capitals")
	}

	// Save deck JSON
	decksDir := filepath.Join(outputDir, "decks")
	if err := builder.SaveJSON(decksDir); err != nil {
		return fmt.Errorf("saving deck: %w", err)
	}

	deckPath := filepath.Join(decksDir, "world-capitals-50.json")
	fmt.Printf("\n=== Generation Complete ===\n")
	fmt.Printf("Deck saved to: %s\n", deckPath)
	fmt.Printf("Media saved to: %s\n", mediaDir)
	fmt.Printf("Total cards: %d\n", len(items))

	return nil
}
