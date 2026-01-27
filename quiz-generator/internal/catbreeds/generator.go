package catbreeds

import (
	"fmt"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/media"
	"github.com/duolingocards/quiz-generator/internal/sparql"
)

// Cat size categories based on typical breed weights
var sizeCategories = map[string]string{
	// Large breeds (over 6kg)
	"Q42365":  "Velká",   // Maine Coon
	"Q182153": "Velká",   // Ragdoll
	"Q188988": "Velká",   // Norwegian Forest Cat
	"Q190109": "Velká",   // British Shorthair
	"Q42373":  "Velká",   // Savannah
	"Q193437": "Velká",   // Ragamuffin
	"Q212089": "Velká",   // Chausie
	"Q211906": "Velká",   // Turkish Van
	"Q190106": "Velká",   // Siberian
	"Q217776": "Velká",   // Chartreux
	"Q186648": "Velká",   // Bengal
	"Q219337": "Velká",   // Selkirk Rex

	// Medium breeds (3-6kg)
	"Q83450":  "Střední", // Persian
	"Q217770": "Střední", // Abyssinian
	"Q186627": "Střední", // Siamese
	"Q43091":  "Střední", // Russian Blue
	"Q188636": "Střední", // Burmese
	"Q191034": "Střední", // Birman
	"Q213044": "Střední", // Scottish Fold
	"Q213005": "Střední", // Egyptian Mau
	"Q178056": "Střední", // American Shorthair
	"Q210726": "Střední", // Exotic Shorthair
	"Q212917": "Střední", // Tonkinese
	"Q191652": "Střední", // Turkish Angora
	"Q185195": "Střední", // Somali
	"Q216628": "Střední", // Ocicat
	"Q183266": "Střední", // Balinese
	"Q213377": "Střední", // Himalayan
	"Q210732": "Střední", // Snowshoe
	"Q204034": "Střední", // Bombay
	"Q210753": "Střední", // Havana Brown
	"Q215682": "Střední", // Japanese Bobtail

	// Small breeds (under 3kg)
	"Q43602":  "Malá",    // Sphynx
	"Q188475": "Malá",    // Cornish Rex
	"Q189249": "Malá",    // Devon Rex
	"Q189267": "Malá",    // Singapura
	"Q189369": "Malá",    // Munchkin
	"Q189265": "Malá",    // American Curl
	"Q213011": "Malá",    // Korat
	"Q213033": "Malá",    // LaPerm
}

// Generator generates quiz items for cat breeds.
type Generator struct {
	sparqlClient *sparql.Client
	downloader   *media.Downloader
}

// New creates a new cat breeds generator.
func New() *Generator {
	return &Generator{
		sparqlClient: sparql.NewClient(),
		downloader:   media.NewDownloader(),
	}
}

// Name returns the generator name.
func (g *Generator) Name() string {
	return "catbreeds"
}

// FetchData fetches cat breed data from Wikidata.
func (g *Generator) FetchData(opts generator.Options) ([]generator.QuizItem, error) {
	query := BuildQuery(opts.Language, opts.Limit*2) // Fetch more to account for filtering

	fmt.Printf("Fetching cat breeds from Wikidata (limit: %d, language: %s)...\n", opts.Limit, opts.Language)

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

	fmt.Printf("Found %d cat breeds\n", len(items))
	return items, nil
}

// DownloadMedia downloads images for all items.
func (g *Generator) DownloadMedia(items []generator.QuizItem, outputDir string) ([]generator.QuizItem, error) {
	fmt.Printf("Downloading %d cat breed images...\n", len(items))

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
