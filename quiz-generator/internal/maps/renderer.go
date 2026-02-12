package maps

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"

	"github.com/duolingocards/quiz-generator/internal/overpass"
)

// Renderer generates map images for geographic features.
type Renderer struct {
	fetcher *TileFetcher
}

// NewRenderer creates a new map renderer with the specified tile source.
func NewRenderer(tileURLFmt string) *Renderer {
	return &Renderer{
		fetcher: NewTileFetcher(tileURLFmt),
	}
}

// SetCacheDir enables tile caching.
func (r *Renderer) SetCacheDir(dir string) {
	r.fetcher.SetCacheDir(dir)
}

// RenderOptions configures map rendering.
type RenderOptions struct {
	// Target image dimensions (will use optimal zoom to fit)
	MaxWidth  int
	MaxHeight int
	// Padding around the feature bounds (in degrees)
	Padding float64
	// Highlight color for the feature
	HighlightColor color.Color
	// Highlight line width
	LineWidth int
	// Zoom override (0 = auto)
	Zoom int
}

// DefaultRenderOptions returns sensible defaults for rendering.
func DefaultRenderOptions() RenderOptions {
	return RenderOptions{
		MaxWidth:       800,
		MaxHeight:      600,
		Padding:        1.0, // 1 degree padding
		HighlightColor: color.RGBA{R: 220, G: 50, B: 50, A: 255}, // Red
		LineWidth:      3,
		Zoom:           0,
	}
}

// RenderFeature renders a map with a highlighted geographic feature.
func (r *Renderer) RenderFeature(bounds *overpass.Bounds, geometry []overpass.LatLon, opts RenderOptions) (image.Image, error) {
	if bounds == nil {
		return nil, fmt.Errorf("bounds required for rendering")
	}

	// Add padding to bounds
	minLat := bounds.MinLat - opts.Padding
	maxLat := bounds.MaxLat + opts.Padding
	minLon := bounds.MinLon - opts.Padding
	maxLon := bounds.MaxLon + opts.Padding

	// Determine zoom level
	zoom := opts.Zoom
	if zoom == 0 {
		zoom = CalculateOptimalZoom(minLat, minLon, maxLat, maxLon, opts.MaxWidth, opts.MaxHeight)
	}

	fmt.Printf("  Rendering at zoom level %d\n", zoom)

	// Fetch base map
	baseMap, err := r.fetcher.FetchAndStitch(minLat, minLon, maxLat, maxLon, zoom)
	if err != nil {
		return nil, fmt.Errorf("fetching base map: %w", err)
	}

	// Convert to RGBA for drawing
	result := toRGBA(baseMap)

	// Draw feature highlight if geometry provided
	if len(geometry) > 0 {
		r.drawPolyline(result, geometry, minLat, minLon, maxLat, maxLon, zoom, opts)
	}

	return result, nil
}

// RenderBoundsOnly renders a map showing just the bounding box area.
// Useful for features where we want to show the region without highlighting.
func (r *Renderer) RenderBoundsOnly(bounds *overpass.Bounds, opts RenderOptions) (image.Image, error) {
	return r.RenderFeature(bounds, nil, opts)
}

// toRGBA converts any image to RGBA.
func toRGBA(img image.Image) *image.RGBA {
	bounds := img.Bounds()
	rgba := image.NewRGBA(bounds)
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			rgba.Set(x, y, img.At(x, y))
		}
	}
	return rgba
}

// drawPolyline draws a polyline on the image.
// Detects gaps between segments and doesn't draw lines across large gaps.
func (r *Renderer) drawPolyline(img *image.RGBA, coords []overpass.LatLon, minLat, minLon, maxLat, maxLon float64, zoom int, opts RenderOptions) {
	if len(coords) < 2 {
		return
	}

	// Get tile grid info for coordinate conversion
	topLeftTile := LatLonToTile(maxLat, minLon, zoom)

	// Convert lat/lon to pixel coordinates
	toPixel := func(lat, lon float64) (int, int) {
		tile := LatLonToTile(lat, lon, zoom)

		// Position within tile
		n := float64(int(1) << zoom)
		xTileFrac := (lon+180.0)/360.0*n - float64(tile.X)
		latRad := lat * 3.14159265358979323846 / 180.0
		yTileFrac := (1.0-((1.0/3.14159265358979323846)*0.5*
			logVal((1+sinVal(latRad))/(1-sinVal(latRad)))))*n/2.0 - float64(tile.Y)

		// Convert to pixel position in stitched image
		px := (tile.X-topLeftTile.X)*TileSize + int(xTileFrac*TileSize)
		py := (tile.Y-topLeftTile.Y)*TileSize + int(yTileFrac*TileSize)

		return px, py
	}

	// Maximum pixel distance to draw a line (prevents cross-segment jumps)
	// Scale threshold based on image size
	imgBounds := img.Bounds()
	maxGap := (imgBounds.Max.X + imgBounds.Max.Y) / 8 // ~12.5% of image dimension

	// Draw line segments, skipping large gaps
	for i := 0; i < len(coords)-1; i++ {
		x1, y1 := toPixel(coords[i].Lat, coords[i].Lon)
		x2, y2 := toPixel(coords[i+1].Lat, coords[i+1].Lon)

		// Calculate pixel distance
		dx := x2 - x1
		dy := y2 - y1
		dist := dx*dx + dy*dy // squared distance is fine for comparison

		// Skip if gap is too large (indicates segment boundary)
		if dist > maxGap*maxGap {
			continue
		}

		drawThickLine(img, x1, y1, x2, y2, opts.HighlightColor, opts.LineWidth)
	}
}

// Simple math helpers to avoid importing math package in hot path
func sinVal(x float64) float64 {
	// Taylor series approximation - good enough for our purposes
	// For more accuracy, use math.Sin
	return x - (x*x*x)/6 + (x*x*x*x*x)/120
}

func logVal(x float64) float64 {
	// Natural log approximation using series
	if x <= 0 {
		return 0
	}
	// Use standard library for accuracy
	return ln(x)
}

// ln computes natural logarithm
func ln(x float64) float64 {
	if x <= 0 {
		return 0
	}
	// Simple iterative method
	result := 0.0
	for x >= 2 {
		x /= 2.7182818284590452353602874713527
		result++
	}
	for x < 0.5 {
		x *= 2.7182818284590452353602874713527
		result--
	}
	// Series expansion around 1
	y := (x - 1) / (x + 1)
	y2 := y * y
	result += 2 * y * (1 + y2/3 + y2*y2/5 + y2*y2*y2/7)
	return result
}

// drawThickLine draws a line with specified thickness using Bresenham's algorithm.
func drawThickLine(img *image.RGBA, x1, y1, x2, y2 int, c color.Color, thickness int) {
	// Draw multiple parallel lines for thickness
	halfT := thickness / 2
	for dy := -halfT; dy <= halfT; dy++ {
		for dx := -halfT; dx <= halfT; dx++ {
			drawLine(img, x1+dx, y1+dy, x2+dx, y2+dy, c)
		}
	}
}

// drawLine draws a 1-pixel line using Bresenham's algorithm.
func drawLine(img *image.RGBA, x1, y1, x2, y2 int, c color.Color) {
	bounds := img.Bounds()

	dx := abs(x2 - x1)
	dy := abs(y2 - y1)
	sx := 1
	if x1 >= x2 {
		sx = -1
	}
	sy := 1
	if y1 >= y2 {
		sy = -1
	}
	err := dx - dy

	for {
		if x1 >= bounds.Min.X && x1 < bounds.Max.X && y1 >= bounds.Min.Y && y1 < bounds.Max.Y {
			img.Set(x1, y1, c)
		}
		if x1 == x2 && y1 == y2 {
			break
		}
		e2 := 2 * err
		if e2 > -dy {
			err -= dy
			x1 += sx
		}
		if e2 < dx {
			err += dx
			y1 += sy
		}
	}
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// SavePNG saves an image to a PNG file.
func SavePNG(img image.Image, path string) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("creating directory: %w", err)
	}

	file, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("creating file: %w", err)
	}
	defer file.Close()

	if err := png.Encode(file, img); err != nil {
		return fmt.Errorf("encoding PNG: %w", err)
	}

	return nil
}
