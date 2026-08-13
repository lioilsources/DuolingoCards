package content

import (
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

// Publishing is what turns images in the repo into images an app can show.
// Two destinations, and a style needs at least one of them (see availability.go):
//
//   - previews: the first few cards of each style, bundled into the app binary
//     so the store can render a deck it has not downloaded.
//   - cdn: the full image set plus deck.json under docs/, served by GitHub
//     Pages and downloaded after unlock.
//
// Only styles with a complete image set are published — the same rule Build
// uses to decide what ships, so the two cannot disagree.

// PublishOptions configures Publish.
type PublishOptions struct {
	// PreviewsDir is the app-bundled preview root (assets/previews).
	PreviewsDir string
	// CDNDir is the published tree root (docs/decks).
	CDNDir string
	// BuiltDir holds the built deck.json files (assets/decks); used to refresh
	// the copy served from CDNDir.
	BuiltDir string
	// PreviewCards is how many leading cards go into the preview set.
	PreviewCards int
	// Style limits publishing to one style (empty = every complete style).
	Style string
	// Images publishes preview and full image sets.
	Images bool
	// WebPQuality, when > 0, re-encodes each published image to WebP at that
	// quality instead of copying the PNG.
	//
	// The PNGs in decks/ stay the lossless masters — only what ships is
	// re-encoded, so a quality change is a re-publish, not a re-render. At q85
	// this is a ~94% saving with no visible difference even on the watercolor
	// style, which is the worst case; the full catalogue does not otherwise fit
	// under the GitHub Pages limit.
	WebPQuality int
	// JSON refreshes <CDNDir>/<slug>/deck.json from BuiltDir.
	//
	// Build reads the published tree to decide availability, so a full run is
	// publish images → build → publish json: the deck.json that reaches the CDN
	// then carries availability that matches what was actually published.
	JSON bool
}

// PublishResult reports what one deck's publish did.
type PublishResult struct {
	Deck     string
	Previews map[string]int // style → files copied
	CDN      map[string]int // style → files copied
	JSON     bool
}

// Publish copies a deck's complete styles into the preview and CDN trees.
func (d *Deck) Publish(opts PublishOptions) (*PublishResult, error) {
	res := &PublishResult{
		Deck:     d.Meta.Slug,
		Previews: map[string]int{},
		CDN:      map[string]int{},
	}

	if opts.Images {
		for _, style := range d.ImageStyles() {
			if opts.Style != "" && opts.Style != style {
				continue
			}
			n, err := d.publishStyle(style, opts)
			if err != nil {
				return nil, err
			}
			res.Previews[style], res.CDN[style] = n.previews, n.cdn
		}
	}

	if opts.JSON && opts.CDNDir != "" && opts.BuiltDir != "" {
		src := filepath.Join(opts.BuiltDir, d.Meta.Slug+".json")
		dst := filepath.Join(opts.CDNDir, d.Meta.Slug, "deck.json")
		if err := copyFile(src, dst); err != nil {
			return nil, fmt.Errorf("publishing deck.json: %w", err)
		}
		res.JSON = true
	}

	return res, nil
}

type styleCounts struct{ previews, cdn int }

func (d *Deck) publishStyle(style string, opts PublishOptions) (styleCounts, error) {
	var n styleCounts
	srcDir := filepath.Join(d.Dir, "images", style)

	for i, c := range d.Meta.Cards {
		if c.Image == "" {
			continue
		}
		src := filepath.Join(srcDir, c.Image)
		out := PublishedImageName(c.Image, opts.WebPQuality > 0)

		if opts.PreviewsDir != "" && i < opts.PreviewCards {
			dst := filepath.Join(opts.PreviewsDir, d.Meta.Slug, style, out)
			if err := placeFile(src, dst, opts.WebPQuality); err != nil {
				return n, fmt.Errorf("preview %s/%s: %w", style, c.Image, err)
			}
			n.previews++
		}
		if opts.CDNDir != "" {
			dst := filepath.Join(opts.CDNDir, d.Meta.Slug, "images", style, out)
			if err := placeFile(src, dst, opts.WebPQuality); err != nil {
				return n, fmt.Errorf("cdn %s/%s: %w", style, c.Image, err)
			}
			n.cdn++
		}
	}
	return n, nil
}

// PublishedImageName is the filename an image has once published: unchanged
// when copying, extension swapped to .webp when re-encoding. build uses the
// same function so deck.json points at the file that actually shipped.
func PublishedImageName(image string, webp bool) string {
	if !webp || image == "" {
		return image
	}
	return strings.TrimSuffix(image, filepath.Ext(image)) + ".webp"
}

// placeFile copies src to dst, or re-encodes it to WebP when quality > 0.
func placeFile(src, dst string, webpQuality int) error {
	if webpQuality <= 0 {
		return copyFile(src, dst)
	}
	return encodeWebP(src, dst, webpQuality)
}

// encodeWebP shells out to cwebp, the reference encoder. Skips work when dst is
// already newer than src, matching copyFile's contract.
//
// An external binary rather than a Go library: the pure-Go encoders are either
// cgo-bound or noticeably worse at these flat, large-area images, and cwebp is
// one `brew install webp` away.
func encodeWebP(src, dst string, quality int) error {
	si, err := os.Stat(src)
	if err != nil {
		return err
	}
	if di, err := os.Stat(dst); err == nil && !di.ModTime().Before(si.ModTime()) {
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}
	tmp := dst + ".tmp.webp"
	cmd := exec.Command("cwebp", "-quiet", "-q", strconv.Itoa(quality), "-m", "6", src, "-o", tmp)
	if out, err := cmd.CombinedOutput(); err != nil {
		os.Remove(tmp)
		if errors.Is(err, exec.ErrNotFound) {
			return fmt.Errorf("cwebp not found — install it (brew install webp) or publish without -webp-quality")
		}
		return fmt.Errorf("cwebp %s: %w: %s", filepath.Base(src), err, out)
	}
	return os.Rename(tmp, dst)
}

// copyFile copies src to dst, creating parents. It skips the write when dst
// already has the same size and is no older than src, so re-publishing a large
// tree does not rewrite every file (and does not churn Git).
func copyFile(src, dst string) error {
	si, err := os.Stat(src)
	if err != nil {
		return err
	}
	if di, err := os.Stat(dst); err == nil {
		if di.Size() == si.Size() && !di.ModTime().Before(si.ModTime()) {
			return nil
		}
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	tmp := dst + ".tmp"
	out, err := os.Create(tmp)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		os.Remove(tmp)
		return err
	}
	if err := out.Close(); err != nil {
		os.Remove(tmp)
		return err
	}
	return os.Rename(tmp, dst)
}
