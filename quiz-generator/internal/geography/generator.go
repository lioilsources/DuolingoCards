package geography

import (
	"fmt"
	"image"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/generator"
	"github.com/duolingocards/quiz-generator/internal/maps"
	"github.com/duolingocards/quiz-generator/internal/overpass"
)

// Generator generates geography quiz items.
type Generator struct {
	overpassClient *overpass.Client
	mapRenderer    *maps.Renderer
	category       string // "mountains", "rivers", "borders"
}

// New creates a new geography generator.
func New(category string) *Generator {
	// Choose tile source based on category
	var tileSource string
	switch category {
	case "mountains":
		// Terrain tiles show elevation - ideal for mountains
		tileSource = maps.OpenTopoMap
	case "rivers":
		// Light map for rivers (we'll overlay the river line)
		tileSource = maps.CartoDBPositronNoLabels
	default:
		tileSource = maps.OpenTopoMap
	}

	return &Generator{
		overpassClient: overpass.NewClient(),
		mapRenderer:    maps.NewRenderer(tileSource),
		category:       category,
	}
}

// Name returns the generator name.
func (g *Generator) Name() string {
	return "geography-" + g.category
}

// FetchData fetches geographic features from OpenStreetMap.
func (g *Generator) FetchData(opts generator.Options) ([]generator.QuizItem, error) {
	switch g.category {
	case "mountains":
		return g.fetchMountains(opts)
	case "rivers":
		return g.fetchRivers(opts)
	default:
		return nil, fmt.Errorf("unknown geography category: %s", g.category)
	}
}

// fetchMountains fetches mountain range data.
func (g *Generator) fetchMountains(opts generator.Options) ([]generator.QuizItem, error) {
	fmt.Printf("Fetching mountain ranges (limit: %d)...\n", opts.Limit)

	var items []generator.QuizItem
	seen := make(map[string]bool)

	// Use curated list for reliable, complete data
	rangesToFetch := MountainRangeNames
	if opts.Limit < len(rangesToFetch) {
		rangesToFetch = rangesToFetch[:opts.Limit]
	}

	for i, name := range rangesToFetch {
		if seen[name] {
			continue
		}
		seen[name] = true

		fmt.Printf("  [%d/%d] Querying %s...\n", i+1, len(rangesToFetch), name)

		// Query Overpass for bounds
		query := QueryMountainRangeByName(name)
		result, err := g.overpassClient.Query(query)
		if err != nil {
			fmt.Printf("    Warning: query failed for %s: %v\n", name, err)
			// Still create item with curated data
		}

		// Get curated metadata
		data, hasCuratedData := MountainRangeData[name]

		var bounds *overpass.Bounds
		if result != nil {
			features := ParseMountainRanges(result)
			if len(features) > 0 {
				bounds = features[0].Bounds
			}
		}

		// Use fallback bounds if Overpass didn't return any
		if bounds == nil {
			bounds = getFallbackBounds(name)
			if bounds == nil {
				fmt.Printf("    Warning: no bounds available for %s, skipping\n", name)
				continue
			}
		}

		// Build quiz item
		item := generator.QuizItem{
			ID:    createSlug(name),
			Title: name,
		}

		// Use Czech name if available
		if hasCuratedData && data.NameCS != "" {
			item.Title = data.NameCS
			item.Subtitle = name // English name as subtitle
		}

		// Add fields
		if hasCuratedData {
			item.Fields = []generator.Field{
				{Label: "Nejvyšší bod", Value: fmt.Sprintf("%s (%s)", data.HighestPeak, data.PeakElevM)},
				{Label: "Délka", Value: data.LengthKm},
				{Label: "Země", Value: data.Countries},
			}
		}

		// Store bounds in ImageURL temporarily (will be used in DownloadMedia)
		item.ImageURL = fmt.Sprintf("bounds:%f,%f,%f,%f",
			bounds.MinLat, bounds.MinLon, bounds.MaxLat, bounds.MaxLon)

		items = append(items, item)

		// Rate limit Overpass queries
		time.Sleep(1 * time.Second)
	}

	fmt.Printf("Found %d mountain ranges\n", len(items))
	return items, nil
}

// fetchRivers fetches river data.
func (g *Generator) fetchRivers(opts generator.Options) ([]generator.QuizItem, error) {
	fmt.Printf("Fetching rivers (limit: %d)...\n", opts.Limit)

	var items []generator.QuizItem
	seen := make(map[string]bool)

	// Use curated list
	riversToFetch := RiverNames
	if opts.Limit < len(riversToFetch) {
		riversToFetch = riversToFetch[:opts.Limit]
	}

	for i, name := range riversToFetch {
		if seen[name] {
			continue
		}
		seen[name] = true

		fmt.Printf("  [%d/%d] Querying %s...\n", i+1, len(riversToFetch), name)

		query := QueryRiverByName(name)
		result, err := g.overpassClient.Query(query)
		if err != nil {
			fmt.Printf("    Warning: query failed for %s: %v\n", name, err)
		}

		data, hasCuratedData := RiverData[name]

		var bounds *overpass.Bounds
		var geometry []overpass.LatLon
		if result != nil {
			features := ParseRivers(result)
			if len(features) > 0 {
				bounds = features[0].Bounds
				geometry = features[0].Geometry
				fmt.Printf("    Got %d geometry points\n", len(geometry))
			}
		}

		if bounds == nil {
			bounds = getRiverFallbackBounds(name)
			if bounds == nil {
				fmt.Printf("    Warning: no bounds for %s, skipping\n", name)
				continue
			}
		}

		item := generator.QuizItem{
			ID:    createSlug(name),
			Title: name,
			Extra: make(map[string]interface{}),
		}

		if hasCuratedData && data.NameCS != "" {
			item.Title = data.NameCS
			item.Subtitle = name
		}

		if hasCuratedData {
			item.Fields = []generator.Field{
				{Label: "Délka", Value: data.LengthKm},
				{Label: "Pramen", Value: data.Source},
				{Label: "Ústí", Value: data.Mouth},
			}
		}

		item.ImageURL = fmt.Sprintf("bounds:%f,%f,%f,%f",
			bounds.MinLat, bounds.MinLon, bounds.MaxLat, bounds.MaxLon)

		// Store geometry for river rendering
		if len(geometry) > 0 {
			item.Extra["geometry"] = geometry
		}

		items = append(items, item)
		time.Sleep(2 * time.Second) // Longer delay for geometry queries
	}

	fmt.Printf("Found %d rivers\n", len(items))
	return items, nil
}

// DownloadMedia generates map images for all items.
func (g *Generator) DownloadMedia(items []generator.QuizItem, outputDir string) ([]generator.QuizItem, error) {
	fmt.Printf("Generating %d map images...\n", len(items))

	// Set up tile cache
	cacheDir := filepath.Join(outputDir, ".tile-cache")
	g.mapRenderer.SetCacheDir(cacheDir)

	updated := make([]generator.QuizItem, len(items))
	copy(updated, items)

	style := maps.StyleForCategory(g.category)

	for i, item := range updated {
		if item.ImageURL == "" || !strings.HasPrefix(item.ImageURL, "bounds:") {
			fmt.Printf("  [%d/%d] %s: no bounds data\n", i+1, len(items), item.ID)
			continue
		}

		// Parse bounds from ImageURL
		var minLat, minLon, maxLat, maxLon float64
		_, err := fmt.Sscanf(item.ImageURL, "bounds:%f,%f,%f,%f",
			&minLat, &minLon, &maxLat, &maxLon)
		if err != nil {
			fmt.Printf("  [%d/%d] %s: invalid bounds format\n", i+1, len(items), item.ID)
			continue
		}

		bounds := &overpass.Bounds{
			MinLat: minLat,
			MinLon: minLon,
			MaxLat: maxLat,
			MaxLon: maxLon,
		}

		fmt.Printf("  [%d/%d] %s: rendering map...\n", i+1, len(items), item.ID)

		// Extract geometry if available (for rivers)
		var geometry []overpass.LatLon
		if item.Extra != nil {
			if geomData, ok := item.Extra["geometry"]; ok {
				if geomSlice, ok := geomData.([]overpass.LatLon); ok {
					geometry = geomSlice
					fmt.Printf("    Using %d geometry points for overlay\n", len(geometry))
				}
			}
		}

		// Render map with or without geometry overlay
		var img image.Image
		if len(geometry) > 0 {
			img, err = g.mapRenderer.RenderFeature(bounds, geometry, style)
		} else {
			img, err = g.mapRenderer.RenderBoundsOnly(bounds, style)
		}
		if err != nil {
			fmt.Printf("    Warning: failed to render %s: %v\n", item.ID, err)
			continue
		}

		// Save PNG
		filename := item.ID + ".png"
		mapPath := filepath.Join(outputDir, filename)
		if err := maps.SavePNG(img, mapPath); err != nil {
			fmt.Printf("    Warning: failed to save %s: %v\n", item.ID, err)
			continue
		}

		updated[i].LocalImage = "maps/" + filename
		updated[i].ImageURL = "" // Clear temporary bounds data
		updated[i].Extra = nil   // Clear extra data
	}

	return updated, nil
}

// createSlug creates a URL-safe identifier from a name.
func createSlug(name string) string {
	// Convert to lowercase
	slug := strings.ToLower(name)

	// Replace spaces and special chars
	slug = strings.ReplaceAll(slug, " ", "-")

	// Remove diacritics (simplified)
	replacements := map[string]string{
		"á": "a", "à": "a", "ä": "a", "â": "a",
		"é": "e", "è": "e", "ë": "e", "ê": "e",
		"í": "i", "ì": "i", "ï": "i", "î": "i",
		"ó": "o", "ò": "o", "ö": "o", "ô": "o",
		"ú": "u", "ù": "u", "ü": "u", "û": "u",
		"ñ": "n", "ç": "c", "ß": "ss",
		"ř": "r", "č": "c", "ž": "z", "š": "s", "ď": "d", "ť": "t", "ň": "n",
		"ě": "e", "ů": "u", "ý": "y",
	}
	for k, v := range replacements {
		slug = strings.ReplaceAll(slug, k, v)
	}

	// Remove any remaining non-alphanumeric characters (except hyphens)
	reg := regexp.MustCompile(`[^a-z0-9-]`)
	slug = reg.ReplaceAllString(slug, "")

	// Remove consecutive hyphens
	reg = regexp.MustCompile(`-+`)
	slug = reg.ReplaceAllString(slug, "-")

	// Trim hyphens from ends
	slug = strings.Trim(slug, "-")

	return slug
}

// getFallbackBounds returns hardcoded bounds for major mountain ranges.
func getFallbackBounds(name string) *overpass.Bounds {
	fallbacks := map[string]*overpass.Bounds{
		"Alps":                   {MinLat: 43.5, MinLon: 5.0, MaxLat: 48.0, MaxLon: 17.0},
		"Himalayas":              {MinLat: 26.0, MinLon: 73.0, MaxLat: 36.0, MaxLon: 95.0},
		"Andes":                  {MinLat: -55.0, MinLon: -80.0, MaxLat: 11.0, MaxLon: -60.0},
		"Rocky Mountains":        {MinLat: 35.0, MinLon: -125.0, MaxLat: 60.0, MaxLon: -105.0},
		"Pyrenees":               {MinLat: 42.0, MinLon: -2.0, MaxLat: 43.5, MaxLon: 3.5},
		"Carpathian Mountains":   {MinLat: 44.0, MinLon: 17.0, MaxLat: 50.0, MaxLon: 27.0},
		"Caucasus Mountains":     {MinLat: 40.0, MinLon: 36.0, MaxLat: 44.0, MaxLon: 50.0},
		"Ural Mountains":         {MinLat: 48.0, MinLon: 52.0, MaxLat: 68.0, MaxLon: 66.0},
		"Atlas Mountains":        {MinLat: 29.0, MinLon: -10.0, MaxLat: 37.0, MaxLon: 12.0},
		"Appalachian Mountains":  {MinLat: 33.0, MinLon: -86.0, MaxLat: 47.0, MaxLon: -69.0},
		"Scandinavian Mountains": {MinLat: 58.0, MinLon: 4.0, MaxLat: 71.0, MaxLon: 20.0},
		"Dinaric Alps":           {MinLat: 41.0, MinLon: 13.0, MaxLat: 46.5, MaxLon: 21.0},
		"Sierra Nevada":          {MinLat: 35.5, MinLon: -120.5, MaxLat: 40.0, MaxLon: -117.5},
		"Tian Shan":              {MinLat: 39.0, MinLon: 67.0, MaxLat: 45.0, MaxLon: 95.0},
		"Kunlun Mountains":       {MinLat: 32.0, MinLon: 77.0, MaxLat: 40.0, MaxLon: 97.0},
		"Karakoram":              {MinLat: 34.0, MinLon: 74.0, MaxLat: 38.0, MaxLon: 80.0},
		"Hindu Kush":             {MinLat: 33.0, MinLon: 68.0, MaxLat: 38.0, MaxLon: 75.0},
		"Drakensberg":            {MinLat: -32.0, MinLon: 27.0, MaxLat: -28.0, MaxLon: 31.0},
		"Great Dividing Range":   {MinLat: -38.0, MinLon: 141.0, MaxLat: -15.0, MaxLon: 153.0},
		"Southern Alps":          {MinLat: -45.5, MinLon: 166.0, MaxLat: -42.0, MaxLon: 173.0},
	}
	return fallbacks[name]
}

// getRiverFallbackBounds returns hardcoded bounds for major rivers.
func getRiverFallbackBounds(name string) *overpass.Bounds {
	fallbacks := map[string]*overpass.Bounds{
		"Amazon":      {MinLat: -10.0, MinLon: -75.0, MaxLat: 5.0, MaxLon: -48.0},
		"Nile":        {MinLat: -3.0, MinLon: 29.0, MaxLat: 32.0, MaxLon: 36.0},
		"Danube":      {MinLat: 42.0, MinLon: 8.0, MaxLat: 50.0, MaxLon: 30.0},
		"Rhine":       {MinLat: 46.0, MinLon: 6.0, MaxLat: 52.0, MaxLon: 10.0},
		"Volga":       {MinLat: 44.0, MinLon: 32.0, MaxLat: 58.0, MaxLon: 50.0},
		"Mississippi": {MinLat: 28.0, MinLon: -95.0, MaxLat: 48.0, MaxLon: -85.0},
		"Yangtze":     {MinLat: 24.0, MinLon: 90.0, MaxLat: 36.0, MaxLon: 122.0},
		"Ganges":      {MinLat: 22.0, MinLon: 78.0, MaxLat: 32.0, MaxLon: 90.0},
		"Mekong":      {MinLat: 9.0, MinLon: 94.0, MaxLat: 34.0, MaxLon: 107.0},
		"Congo":       {MinLat: -13.0, MinLon: 12.0, MaxLat: 4.0, MaxLon: 32.0},
	}
	return fallbacks[name]
}
