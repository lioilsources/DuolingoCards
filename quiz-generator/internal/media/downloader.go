package media

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// Downloader handles downloading and processing media files.
type Downloader struct {
	httpClient *http.Client
	userAgent  string
}

// NewDownloader creates a new media downloader.
func NewDownloader() *Downloader {
	return &Downloader{
		httpClient: &http.Client{
			Timeout: 60 * time.Second,
		},
		userAgent: "DuolingoCards-QuizGenerator/1.0",
	}
}

// DownloadFile downloads a file from URL to the specified path.
func (d *Downloader) DownloadFile(url, destPath string) error {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return fmt.Errorf("creating request: %w", err)
	}

	req.Header.Set("User-Agent", d.userAgent)

	resp, err := d.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("downloading %s: %w", url, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("download returned status %d for %s", resp.StatusCode, url)
	}

	// Create destination directory if needed
	dir := filepath.Dir(destPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("creating directory %s: %w", dir, err)
	}

	out, err := os.Create(destPath)
	if err != nil {
		return fmt.Errorf("creating file %s: %w", destPath, err)
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	if err != nil {
		return fmt.Errorf("writing file %s: %w", destPath, err)
	}

	return nil
}

// ConvertSVGtoPNG converts an SVG file to PNG using ImageMagick or rsvg-convert.
func (d *Downloader) ConvertSVGtoPNG(svgPath, pngPath string, width int) error {
	// Try rsvg-convert first (better SVG support)
	if _, err := exec.LookPath("rsvg-convert"); err == nil {
		cmd := exec.Command("rsvg-convert", "-w", fmt.Sprintf("%d", width), "-o", pngPath, svgPath)
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("rsvg-convert failed: %w", err)
		}
		return nil
	}

	// Fall back to ImageMagick
	if _, err := exec.LookPath("convert"); err == nil {
		cmd := exec.Command("convert", "-background", "none", "-resize", fmt.Sprintf("%dx", width), svgPath, pngPath)
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("imagemagick convert failed: %w", err)
		}
		return nil
	}

	return fmt.Errorf("neither rsvg-convert nor imagemagick found, cannot convert SVG to PNG")
}

// DownloadAndConvert downloads an image and converts to PNG if necessary.
// Returns the local filename.
func (d *Downloader) DownloadAndConvert(url, outputDir, baseName string, pngWidth int) (string, error) {
	// Determine file extension from URL
	ext := strings.ToLower(filepath.Ext(url))
	if ext == "" {
		ext = ".png"
	}

	// Handle special case where URL has query params
	if idx := strings.Index(ext, "?"); idx != -1 {
		ext = ext[:idx]
	}

	tempPath := filepath.Join(outputDir, baseName+ext)
	finalPath := filepath.Join(outputDir, baseName+".png")

	// Download the file
	if err := d.DownloadFile(url, tempPath); err != nil {
		return "", err
	}

	// Convert SVG to PNG if necessary
	if ext == ".svg" {
		if err := d.ConvertSVGtoPNG(tempPath, finalPath, pngWidth); err != nil {
			return "", err
		}
		// Remove temporary SVG file
		os.Remove(tempPath)
		return baseName + ".png", nil
	}

	// If already PNG, we're done
	if ext == ".png" {
		return baseName + ".png", nil
	}

	// For other formats, convert to PNG using ImageMagick
	if _, err := exec.LookPath("convert"); err == nil {
		cmd := exec.Command("convert", tempPath, finalPath)
		if err := cmd.Run(); err != nil {
			// If conversion fails, keep the original
			return baseName + ext, nil
		}
		os.Remove(tempPath)
		return baseName + ".png", nil
	}

	// Keep original format if no conversion tool available
	return baseName + ext, nil
}
