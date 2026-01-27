package dogbreeds

import (
	"fmt"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/media"
	"github.com/duolingocards/quiz-generator/internal/sparql"
)

// Dog size categories based on typical breed weights
var sizeCategories = map[string]string{
	// Large breeds (over 25kg)
	"Q5765":   "Velký",   // German Shepherd
	"Q39062":  "Velký",   // Golden Retriever
	"Q39084":  "Velký",   // Labrador Retriever
	"Q192365": "Velký",   // Rottweiler
	"Q243458": "Velký",   // Doberman
	"Q134649": "Velký",   // Great Dane
	"Q39021":  "Velký",   // Saint Bernard
	"Q37652":  "Velký",   // Siberian Husky
	"Q184714": "Velký",   // Boxer
	"Q205594": "Velký",   // Bernese Mountain Dog
	"Q193119": "Velký",   // Irish Setter
	"Q219373": "Velký",   // Weimaraner
	"Q176139": "Velký",   // Akita
	"Q327508": "Velký",   // Alaskan Malamute
	"Q1098647": "Velký",  // Belgian Malinois
	"Q208212": "Velký",   // Rhodesian Ridgeback
	"Q26867":  "Velký",   // Newfoundland
	"Q241478": "Velký",   // Irish Wolfhound
	"Q161548": "Velký",   // Collie
	"Q26745":  "Velký",   // Dalmatian

	// Medium breeds (10-25kg)
	"Q45122":  "Střední", // Bulldog
	"Q208149": "Střední", // Border Collie
	"Q205476": "Střední", // Cocker Spaniel
	"Q178258": "Střední", // Beagle
	"Q165257": "Střední", // Basset Hound
	"Q38565":  "Střední", // Poodle (Standard)
	"Q329949": "Střední", // Australian Shepherd
	"Q172865": "Střední", // Shar Pei
	"Q212813": "Střední", // Whippet
	"Q183188": "Střední", // Brittany
	"Q220685": "Střední", // Samoyed
	"Q203244": "Střední", // English Springer Spaniel
	"Q39041":  "Střední", // Chow Chow
	"Q37702":  "Střední", // Shiba Inu
	"Q275473": "Střední", // Bull Terrier
	"Q188915": "Střední", // Staffordshire Bull Terrier

	// Small breeds (under 10kg)
	"Q26868":  "Malý",    // Chihuahua
	"Q38571":  "Malý",    // Pomeranian
	"Q327499": "Malý",    // Yorkshire Terrier
	"Q205060": "Malý",    // Shih Tzu
	"Q165447": "Malý",    // Dachshund
	"Q161462": "Malý",    // Miniature Schnauzer
	"Q38545":  "Malý",    // Maltese
	"Q180973": "Malý",    // Pug
	"Q159348": "Malý",    // French Bulldog
	"Q207536": "Malý",    // Cavalier King Charles Spaniel
	"Q185096": "Malý",    // Bichon Frise
	"Q161117": "Malý",    // Papillon
	"Q38649":  "Malý",    // Pekingese
	"Q191652": "Malý",    // Jack Russell Terrier
	"Q184962": "Malý",    // Boston Terrier
	"Q38573":  "Malý",    // West Highland White Terrier
	"Q26823":  "Malý",    // Havanese
}

// Generator generates quiz items for dog breeds.
type Generator struct {
	sparqlClient *sparql.Client
	downloader   *media.Downloader
}

// New creates a new dog breeds generator.
func New() *Generator {
	return &Generator{
		sparqlClient: sparql.NewClient(),
		downloader:   media.NewDownloader(),
	}
}

// Name returns the generator name.
func (g *Generator) Name() string {
	return "dogbreeds"
}

// FetchData fetches dog breed data from Wikidata.
func (g *Generator) FetchData(opts generator.Options) ([]generator.QuizItem, error) {
	query := BuildQuery(opts.Language, opts.Limit*2) // Fetch more to account for filtering

	fmt.Printf("Fetching dog breeds from Wikidata (limit: %d, language: %s)...\n", opts.Limit, opts.Language)

	result, err := g.sparqlClient.Query(query)
	if err != nil {
		return nil, fmt.Errorf("SPARQL query failed: %w", err)
	}

	var items []generator.QuizItem
	seen := make(map[string]bool)

	for _, binding := range result.Results.Bindings {
		// Extract Wikidata ID from breed URI
		breedURI := sparql.GetValue(binding, "breed")
		wikidataID := ""
		if idx := strings.LastIndex(breedURI, "/"); idx != -1 {
			wikidataID = breedURI[idx+1:]
		}

		if wikidataID == "" || seen[wikidataID] {
			continue
		}
		seen[wikidataID] = true

		breedLabel := sparql.GetValue(binding, "breedLabel")
		breedLabelEn := sparql.GetValue(binding, "breedLabelEn")
		imageURL := sparql.GetValue(binding, "image")
		originLabel := sparql.GetValue(binding, "originLabel")

		// Skip if label is just the Q-ID (unlabeled)
		if strings.HasPrefix(breedLabel, "Q") {
			continue
		}

		// Use English label as subtitle if different
		subtitle := ""
		if breedLabelEn != "" && breedLabelEn != breedLabel {
			subtitle = breedLabelEn
		}

		// Determine size category
		size := getSizeCategory(wikidataID)

		// Build fields
		fields := []generator.Field{}
		if originLabel != "" && !strings.HasPrefix(originLabel, "Q") {
			fields = append(fields, generator.Field{Label: "Původ", Value: originLabel})
		}
		fields = append(fields, generator.Field{Label: "Velikost", Value: size})

		// Create slug ID from label
		slugID := createSlug(breedLabel)
		if slugID == "" {
			slugID = wikidataID
		}

		item := generator.QuizItem{
			ID:         slugID,
			Title:      breedLabel,
			Subtitle:   subtitle,
			ImageURL:   imageURL,
			Fields:     fields,
			WikidataID: wikidataID,
		}

		items = append(items, item)

		if len(items) >= opts.Limit {
			break
		}
	}

	fmt.Printf("Found %d dog breeds\n", len(items))
	return items, nil
}

// DownloadMedia downloads images for all items.
func (g *Generator) DownloadMedia(items []generator.QuizItem, outputDir string) ([]generator.QuizItem, error) {
	fmt.Printf("Downloading %d dog breed images...\n", len(items))

	updated := make([]generator.QuizItem, len(items))
	copy(updated, items)

	for i, item := range updated {
		if item.ImageURL == "" {
			fmt.Printf("  [%d/%d] %s: no image URL\n", i+1, len(items), item.ID)
			continue
		}

		fmt.Printf("  [%d/%d] %s: downloading image...\n", i+1, len(items), item.ID)

		localFile, err := g.downloader.DownloadAndConvert(item.ImageURL, outputDir, item.ID, 512)
		if err != nil {
			fmt.Printf("    Warning: failed to download %s: %v\n", item.ID, err)
			continue
		}

		updated[i].LocalImage = "images/" + localFile

		// Be nice to Wikimedia servers
		time.Sleep(300 * time.Millisecond)
	}

	return updated, nil
}

// getSizeCategory returns the size category for a breed by Wikidata ID.
func getSizeCategory(wikidataID string) string {
	if size, ok := sizeCategories[wikidataID]; ok {
		return size
	}
	return "Střední" // Default to medium if unknown
}

// createSlug creates a URL-safe slug from a label.
func createSlug(label string) string {
	slug := strings.ToLower(label)
	slug = strings.Map(func(r rune) rune {
		switch {
		case r >= 'a' && r <= 'z':
			return r
		case r >= '0' && r <= '9':
			return r
		case r == ' ' || r == '-' || r == '_':
			return '-'
		case r == 'á' || r == 'à' || r == 'â' || r == 'ä':
			return 'a'
		case r == 'é' || r == 'è' || r == 'ê' || r == 'ë':
			return 'e'
		case r == 'í' || r == 'ì' || r == 'î' || r == 'ï':
			return 'i'
		case r == 'ó' || r == 'ò' || r == 'ô' || r == 'ö':
			return 'o'
		case r == 'ú' || r == 'ù' || r == 'û' || r == 'ü':
			return 'u'
		case r == 'ý' || r == 'ÿ':
			return 'y'
		case r == 'ñ':
			return 'n'
		case r == 'č' || r == 'ç':
			return 'c'
		case r == 'ř':
			return 'r'
		case r == 'š':
			return 's'
		case r == 'ž':
			return 'z'
		case r == 'ě':
			return 'e'
		case r == 'ď':
			return 'd'
		case r == 'ť':
			return 't'
		case r == 'ň':
			return 'n'
		case r == 'ů':
			return 'u'
		default:
			return -1
		}
	}, slug)

	// Remove consecutive dashes
	for strings.Contains(slug, "--") {
		slug = strings.ReplaceAll(slug, "--", "-")
	}
	slug = strings.Trim(slug, "-")

	return slug
}
