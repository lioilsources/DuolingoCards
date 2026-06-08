package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/duolingocards/quiz-generator/internal/capitals"
	"github.com/duolingocards/quiz-generator/internal/catbreeds"
	"github.com/duolingocards/quiz-generator/internal/comfyuiimage"
	"github.com/duolingocards/quiz-generator/internal/deck"
	"github.com/duolingocards/quiz-generator/internal/dogbreeds"
	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/geography"
	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/pokemon"
)

func main() {
	// CLI flags
	genType := flag.String("type", "capitals", "Type of quiz to generate (capitals, dogbreeds, catbreeds, geography, pokemon)")
	category := flag.String("category", "mountains", "Category for geography type (mountains, rivers)")
	limit := flag.Int("limit", 50, "Maximum number of items to fetch")
	lang := flag.String("lang", "cs", "Language code for labels (cs, en, de, etc.)")
	outputDir := flag.String("output", "output", "Output directory for generated files")
	backend := flag.String("backend", "none", "Image generation backend for items without photos: none, comfyui")
	comfyURL := flag.String("comfyui-url", "", "ComfyUI server URL (overrides COMFYUI_API_URL env var)")
	comfyTimeout := flag.Duration("comfyui-timeout", 15*time.Minute, "Max wait time per ComfyUI job")
	flag.Parse()

	opts := generator.Options{
		Limit:    *limit,
		Language: *lang,
	}

	// Build optional image generator based on -backend flag.
	var imageGen imagegen.ImageGenerator
	if *backend == "comfyui" {
		url := *comfyURL
		if url == "" {
			url = os.Getenv("COMFYUI_API_URL")
		}
		if url == "" {
			fmt.Fprintln(os.Stderr, "Error: -backend=comfyui requires -comfyui-url or COMFYUI_API_URL env var")
			os.Exit(1)
		}
		cfID := os.Getenv("CF_ACCESS_CLIENT_ID")
		cfSecret := os.Getenv("CF_ACCESS_CLIENT_SECRET")
		imageGen = comfyuiimage.NewClient(url, cfID, cfSecret, comfyuiimage.WithJobTimeout(*comfyTimeout))
	}

	switch *genType {
	case "capitals":
		if err := generateCapitals(opts, *outputDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	case "dogbreeds":
		if err := generateDogBreeds(opts, *outputDir, imageGen); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	case "catbreeds":
		if err := generateCatBreeds(opts, *outputDir, imageGen); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	case "geography":
		if err := generateGeography(opts, *outputDir, *category); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	case "pokemon":
		if err := generatePokemon(opts, *outputDir); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	default:
		fmt.Fprintf(os.Stderr, "Unknown generator type: %s\n", *genType)
		fmt.Fprintf(os.Stderr, "Available types: capitals, dogbreeds, catbreeds, geography, pokemon\n")
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

func generateDogBreeds(opts generator.Options, outputDir string, imageGen imagegen.ImageGenerator) error {
	var genOpts []func(*dogbreeds.Generator)
	if imageGen != nil {
		genOpts = append(genOpts, dogbreeds.WithImageGenerator(imageGen))
	}
	gen := dogbreeds.New(genOpts...)

	fmt.Println("=== Dog Breeds Quiz Generator ===")
	fmt.Printf("Language: %s, Limit: %d\n\n", opts.Language, opts.Limit)

	// Fetch data from Wikidata
	items, err := gen.FetchData(opts)
	if err != nil {
		return fmt.Errorf("fetching data: %w", err)
	}

	if len(items) == 0 {
		return fmt.Errorf("no data returned from Wikidata")
	}

	// Download media (images)
	mediaDir := filepath.Join(outputDir, "media", "dogs")
	items, err = gen.DownloadMedia(items, mediaDir)
	if err != nil {
		return fmt.Errorf("downloading media: %w", err)
	}

	// Build deck
	builder := deck.NewBuilder(
		"dog-breeds-50",
		"Psí plemena",
		"50 nejrozšířenějších psích plemen s obrázky",
		opts.Language,
		"assets/media/dog-breeds-50",
	)

	for _, item := range items {
		builder.AddCard(item, "dogbreeds")
	}

	// Save deck JSON
	decksDir := filepath.Join(outputDir, "decks")
	if err := builder.SaveJSON(decksDir); err != nil {
		return fmt.Errorf("saving deck: %w", err)
	}

	deckPath := filepath.Join(decksDir, "dog-breeds-50.json")
	fmt.Printf("\n=== Generation Complete ===\n")
	fmt.Printf("Deck saved to: %s\n", deckPath)
	fmt.Printf("Media saved to: %s\n", mediaDir)
	fmt.Printf("Total cards: %d\n", len(items))

	return nil
}

func generateCatBreeds(opts generator.Options, outputDir string, imageGen imagegen.ImageGenerator) error {
	var genOpts []func(*catbreeds.Generator)
	if imageGen != nil {
		genOpts = append(genOpts, catbreeds.WithImageGenerator(imageGen))
	}
	gen := catbreeds.New(genOpts...)

	fmt.Println("=== Cat Breeds Quiz Generator ===")
	fmt.Printf("Language: %s, Limit: %d\n\n", opts.Language, opts.Limit)

	// Fetch data from Wikidata
	items, err := gen.FetchData(opts)
	if err != nil {
		return fmt.Errorf("fetching data: %w", err)
	}

	if len(items) == 0 {
		return fmt.Errorf("no data returned from Wikidata")
	}

	// Download media (images)
	mediaDir := filepath.Join(outputDir, "media", "cats")
	items, err = gen.DownloadMedia(items, mediaDir)
	if err != nil {
		return fmt.Errorf("downloading media: %w", err)
	}

	// Build deck
	builder := deck.NewBuilder(
		"cat-breeds-50",
		"Kočičí plemena",
		"50 nejrozšířenějších kočičích plemen s obrázky",
		opts.Language,
		"assets/media/cat-breeds-50",
	)

	for _, item := range items {
		builder.AddCard(item, "catbreeds")
	}

	// Save deck JSON
	decksDir := filepath.Join(outputDir, "decks")
	if err := builder.SaveJSON(decksDir); err != nil {
		return fmt.Errorf("saving deck: %w", err)
	}

	deckPath := filepath.Join(decksDir, "cat-breeds-50.json")
	fmt.Printf("\n=== Generation Complete ===\n")
	fmt.Printf("Deck saved to: %s\n", deckPath)
	fmt.Printf("Media saved to: %s\n", mediaDir)
	fmt.Printf("Total cards: %d\n", len(items))

	return nil
}

func generatePokemon(opts generator.Options, outputDir string) error {
	gen := pokemon.New()

	fmt.Println("=== Pokémon Quiz Generator ===")
	fmt.Printf("Language: %s, Limit: %d\n\n", opts.Language, opts.Limit)

	// Fetch data from PokéAPI
	items, err := gen.FetchData(opts)
	if err != nil {
		return fmt.Errorf("fetching data: %w", err)
	}

	if len(items) == 0 {
		return fmt.Errorf("no data returned from PokéAPI")
	}

	// Download media (official artwork)
	deckID := fmt.Sprintf("pokemon-gen1-%d", opts.Limit)
	mediaDir := filepath.Join(outputDir, "media", deckID, "images")
	items, err = gen.DownloadMedia(items, mediaDir)
	if err != nil {
		return fmt.Errorf("downloading media: %w", err)
	}

	// Build deck
	builder := deck.NewBuilder(
		deckID,
		"Pokémoni",
		fmt.Sprintf("Kvíz o %d Pokémonech s oficiálními obrázky a statistikami", len(items)),
		opts.Language,
		fmt.Sprintf("assets/media/%s", deckID),
	)

	for _, item := range items {
		builder.AddCard(item, "pokemon")
	}

	// Save deck JSON
	decksDir := filepath.Join(outputDir, "decks")
	if err := builder.SaveJSON(decksDir); err != nil {
		return fmt.Errorf("saving deck: %w", err)
	}

	deckPath := filepath.Join(decksDir, deckID+".json")
	fmt.Printf("\n=== Generation Complete ===\n")
	fmt.Printf("Deck saved to: %s\n", deckPath)
	fmt.Printf("Media saved to: %s\n", mediaDir)
	fmt.Printf("Total cards: %d\n", len(items))

	return nil
}

func generateGeography(opts generator.Options, outputDir string, category string) error {
	gen := geography.New(category)

	fmt.Printf("=== Geography Quiz Generator ===\n")
	fmt.Printf("Category: %s, Language: %s, Limit: %d\n\n", category, opts.Language, opts.Limit)

	// Fetch data from OpenStreetMap
	items, err := gen.FetchData(opts)
	if err != nil {
		return fmt.Errorf("fetching data: %w", err)
	}

	if len(items) == 0 {
		return fmt.Errorf("no data returned from OpenStreetMap")
	}

	// Generate map images
	deckID := fmt.Sprintf("geography-%s-%d", category, opts.Limit)
	mediaDir := filepath.Join(outputDir, "media", deckID, "maps")
	items, err = gen.DownloadMedia(items, mediaDir)
	if err != nil {
		return fmt.Errorf("generating maps: %w", err)
	}

	// Build deck
	var deckName, deckDesc string
	switch category {
	case "mountains":
		deckName = "Světová pohoří"
		deckDesc = fmt.Sprintf("Kvíz o %d nejznámějších pohořích světa s němými mapami", opts.Limit)
	case "rivers":
		deckName = "Světové řeky"
		deckDesc = fmt.Sprintf("Kvíz o %d nejznámějších řekách světa s němými mapami", opts.Limit)
	default:
		deckName = "Geografie"
		deckDesc = "Geografický kvíz"
	}

	builder := deck.NewBuilder(
		deckID,
		deckName,
		deckDesc,
		opts.Language,
		fmt.Sprintf("assets/media/%s", deckID),
	)

	for _, item := range items {
		builder.AddCard(item, category)
	}

	// Save deck JSON
	decksDir := filepath.Join(outputDir, "decks")
	if err := builder.SaveJSON(decksDir); err != nil {
		return fmt.Errorf("saving deck: %w", err)
	}

	deckPath := filepath.Join(decksDir, deckID+".json")
	fmt.Printf("\n=== Generation Complete ===\n")
	fmt.Printf("Deck saved to: %s\n", deckPath)
	fmt.Printf("Media saved to: %s\n", mediaDir)
	fmt.Printf("Total cards: %d\n", len(items))

	return nil
}
