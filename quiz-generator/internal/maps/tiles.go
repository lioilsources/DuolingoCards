package maps

import (
	"fmt"
	"image"
	"image/png"
	"io"
	"math"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

const (
	// TileSize is the standard OSM tile size in pixels.
	TileSize = 256

	// StamenTerrainBackground provides terrain tiles without labels (via Stadia Maps).
	// Note: Free tier available, check https://stadiamaps.com for current limits.
	StamenTerrainBackground = "https://tiles.stadiamaps.com/tiles/stamen_terrain_background/%d/%d/%d.png"

	// OpenTopoMap provides topographic maps.
	OpenTopoMap = "https://tile.opentopomap.org/%d/%d/%d.png"

	// CartoDB Positron (light, no labels)
	CartoDBPositronNoLabels = "https://basemaps.cartocdn.com/light_nolabels/%d/%d/%d.png"
)

// TileFetcher downloads map tiles from tile servers.
type TileFetcher struct {
	httpClient   *http.Client
	userAgent    string
	tileURLFmt   string
	cacheDir     string
	requestDelay time.Duration
}

// NewTileFetcher creates a new tile fetcher.
func NewTileFetcher(tileURLFmt string) *TileFetcher {
	return &TileFetcher{
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		userAgent:    "DuolingoCards-QuizGenerator/1.0 (educational flashcard app)",
		tileURLFmt:   tileURLFmt,
		requestDelay: 100 * time.Millisecond, // Be respectful to tile servers
	}
}

// SetCacheDir enables tile caching in the specified directory.
func (f *TileFetcher) SetCacheDir(dir string) {
	f.cacheDir = dir
}

// TileCoord represents a tile coordinate.
type TileCoord struct {
	Z, X, Y int
}

// LatLonToTile converts lat/lon to tile coordinates at a given zoom level.
func LatLonToTile(lat, lon float64, zoom int) TileCoord {
	n := math.Pow(2, float64(zoom))
	x := int((lon + 180.0) / 360.0 * n)
	latRad := lat * math.Pi / 180.0
	y := int((1.0 - math.Log(math.Tan(latRad)+1.0/math.Cos(latRad))/math.Pi) / 2.0 * n)

	// Clamp values
	maxTile := int(n) - 1
	if x < 0 {
		x = 0
	}
	if x > maxTile {
		x = maxTile
	}
	if y < 0 {
		y = 0
	}
	if y > maxTile {
		y = maxTile
	}

	return TileCoord{Z: zoom, X: x, Y: y}
}

// TileToLatLon converts tile coordinates to lat/lon (top-left corner of tile).
func TileToLatLon(t TileCoord) (lat, lon float64) {
	n := math.Pow(2, float64(t.Z))
	lon = float64(t.X)/n*360.0 - 180.0
	latRad := math.Atan(math.Sinh(math.Pi * (1 - 2*float64(t.Y)/n)))
	lat = latRad * 180.0 / math.Pi
	return lat, lon
}

// BoundsToTiles returns all tile coordinates covering a bounding box.
func BoundsToTiles(minLat, minLon, maxLat, maxLon float64, zoom int) []TileCoord {
	// Get corner tiles
	topLeft := LatLonToTile(maxLat, minLon, zoom)
	bottomRight := LatLonToTile(minLat, maxLon, zoom)

	var tiles []TileCoord
	for x := topLeft.X; x <= bottomRight.X; x++ {
		for y := topLeft.Y; y <= bottomRight.Y; y++ {
			tiles = append(tiles, TileCoord{Z: zoom, X: x, Y: y})
		}
	}
	return tiles
}

// FetchTile downloads a single tile and returns it as an image.
func (f *TileFetcher) FetchTile(t TileCoord) (image.Image, error) {
	// Check cache first
	if f.cacheDir != "" {
		cachePath := filepath.Join(f.cacheDir, fmt.Sprintf("%d_%d_%d.png", t.Z, t.X, t.Y))
		if file, err := os.Open(cachePath); err == nil {
			defer file.Close()
			return png.Decode(file)
		}
	}

	url := fmt.Sprintf(f.tileURLFmt, t.Z, t.X, t.Y)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("creating request: %w", err)
	}
	req.Header.Set("User-Agent", f.userAgent)

	resp, err := f.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetching tile %d/%d/%d: %w", t.Z, t.X, t.Y, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("tile server returned %d for %d/%d/%d", resp.StatusCode, t.Z, t.X, t.Y)
	}

	// Read into memory for caching
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("reading tile data: %w", err)
	}

	// Cache if enabled
	if f.cacheDir != "" {
		cachePath := filepath.Join(f.cacheDir, fmt.Sprintf("%d_%d_%d.png", t.Z, t.X, t.Y))
		os.MkdirAll(f.cacheDir, 0755)
		os.WriteFile(cachePath, data, 0644)
	}

	// Decode image
	img, err := png.Decode(io.NopCloser(io.Reader(io.NopCloser(
		&byteReader{data: data},
	))))
	if err != nil {
		// Try generic decode
		return nil, fmt.Errorf("decoding tile image: %w", err)
	}

	// Rate limit
	time.Sleep(f.requestDelay)

	return img, nil
}

type byteReader struct {
	data []byte
	pos  int
}

func (r *byteReader) Read(p []byte) (n int, err error) {
	if r.pos >= len(r.data) {
		return 0, io.EOF
	}
	n = copy(p, r.data[r.pos:])
	r.pos += n
	return n, nil
}

// FetchAndStitch downloads all tiles for a bounding box and stitches them together.
func (f *TileFetcher) FetchAndStitch(minLat, minLon, maxLat, maxLon float64, zoom int) (image.Image, error) {
	tiles := BoundsToTiles(minLat, minLon, maxLat, maxLon, zoom)
	if len(tiles) == 0 {
		return nil, fmt.Errorf("no tiles found for bounds")
	}

	// Find grid dimensions
	minX, minY := tiles[0].X, tiles[0].Y
	maxX, maxY := tiles[0].X, tiles[0].Y
	for _, t := range tiles {
		if t.X < minX {
			minX = t.X
		}
		if t.X > maxX {
			maxX = t.X
		}
		if t.Y < minY {
			minY = t.Y
		}
		if t.Y > maxY {
			maxY = t.Y
		}
	}

	width := (maxX - minX + 1) * TileSize
	height := (maxY - minY + 1) * TileSize

	// Create output image
	result := image.NewRGBA(image.Rect(0, 0, width, height))

	// Fetch and place each tile
	for _, t := range tiles {
		tile, err := f.FetchTile(t)
		if err != nil {
			fmt.Printf("Warning: failed to fetch tile %d/%d/%d: %v\n", t.Z, t.X, t.Y, err)
			continue
		}

		// Calculate position in result image
		destX := (t.X - minX) * TileSize
		destY := (t.Y - minY) * TileSize

		// Copy tile to result
		for y := 0; y < TileSize; y++ {
			for x := 0; x < TileSize; x++ {
				result.Set(destX+x, destY+y, tile.At(x, y))
			}
		}
	}

	return result, nil
}

// CalculateOptimalZoom determines the best zoom level for a bounding box
// to fit within the target dimensions while maximizing detail.
func CalculateOptimalZoom(minLat, minLon, maxLat, maxLon float64, maxWidth, maxHeight int) int {
	for zoom := 10; zoom >= 1; zoom-- {
		tiles := BoundsToTiles(minLat, minLon, maxLat, maxLon, zoom)

		minX, minY := tiles[0].X, tiles[0].Y
		maxX, maxY := tiles[0].X, tiles[0].Y
		for _, t := range tiles {
			if t.X < minX {
				minX = t.X
			}
			if t.X > maxX {
				maxX = t.X
			}
			if t.Y < minY {
				minY = t.Y
			}
			if t.Y > maxY {
				maxY = t.Y
			}
		}

		width := (maxX - minX + 1) * TileSize
		height := (maxY - minY + 1) * TileSize

		if width <= maxWidth && height <= maxHeight {
			return zoom
		}
	}
	return 1
}
