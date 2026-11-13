package content

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// The remote catalog (docs/catalog.json on GitHub Pages) is what lets a deck
// reach the store without an app release. It is the bundled
// assets/catalog.json (free list + IAP products) plus a `decks` index of every
// deck published under docs/decks/, so an app that has never bundled a deck
// can still list it, price it and download it.
//
// Generation must be deterministic: `make ship` runs it on every publish, and a
// file that changed on every run would churn Git. The only time-dependent
// field is `added`, and that is carried over from the previous catalog — a
// deck gets today's date once, the first time it is published, and keeps it.

// CatalogDeck is one entry of the remote catalog's deck index.
type CatalogDeck struct {
	Slug         string            `json:"slug"`
	Version      int               `json:"version"`
	Tier         int               `json:"tier"`
	Added        string            `json:"added"` // ISO date, YYYY-MM-DD
	DefaultStyle string            `json:"defaultStyle"`
	Styles       []string          `json:"styles"` // styles downloadable from the CDN
	Cards        int               `json:"cards"`
	Titles       map[string]string `json:"titles"`
}

// RemoteCatalog is the document written to docs/catalog.json.
type RemoteCatalog struct {
	Schema   int               `json:"schema"`
	Free     []string          `json:"free"`
	Products []json.RawMessage `json:"products"`
	Decks    []CatalogDeck     `json:"decks"`
}

// CatalogOptions configures BuildRemoteCatalog.
type CatalogOptions struct {
	// Source is the bundled catalog (assets/catalog.json): free list + products.
	Source string
	// BuiltDir holds built deck.json files (assets/decks/<slug>.json).
	BuiltDir string
	// CDNDir is the published tree (docs/decks); only decks published there are
	// indexed, since a deck the CDN cannot serve cannot be downloaded.
	CDNDir string
	// Previous is the catalog being replaced, read for `added` dates. A missing
	// file is fine (first run).
	Previous string
	// Today stamps decks that appear for the first time.
	Today time.Time
}

// builtDeck is the slice of a built deck.json the catalog needs.
type builtDeck struct {
	Deck              string                       `json:"deck"`
	Version           int                          `json:"version"`
	Tier              int                          `json:"tier"`
	Styles            []string                     `json:"styles"`
	StyleAvailability map[string]StyleAvailability `json:"styleAvailability"`
	DefaultStyle      string                       `json:"defaultStyle"`
	Titles            map[string]string            `json:"titles"`
	Cards             []json.RawMessage            `json:"cards"`
}

// BuildRemoteCatalog assembles the remote catalog from the bundled catalog and
// the published decks. Decks are sorted by slug.
func BuildRemoteCatalog(opts CatalogOptions) (*RemoteCatalog, error) {
	var src struct {
		Free     []string          `json:"free"`
		Products []json.RawMessage `json:"products"`
	}
	raw, err := os.ReadFile(opts.Source)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", opts.Source, err)
	}
	if err := json.Unmarshal(raw, &src); err != nil {
		return nil, fmt.Errorf("parsing %s: %w", opts.Source, err)
	}

	previous := previousAdded(opts.Previous)
	today := opts.Today.UTC().Format("2006-01-02")

	files, err := filepath.Glob(filepath.Join(opts.BuiltDir, "*.json"))
	if err != nil {
		return nil, err
	}
	sort.Strings(files)

	cat := &RemoteCatalog{
		Schema:   1,
		Free:     nonNil(src.Free),
		Products: src.Products,
		Decks:    []CatalogDeck{},
	}
	if cat.Products == nil {
		cat.Products = []json.RawMessage{}
	}
	for _, f := range files {
		slug := strings.TrimSuffix(filepath.Base(f), ".json")
		if _, err := os.Stat(filepath.Join(opts.CDNDir, slug, "deck.json")); err != nil {
			continue // not published: the app could not download it
		}
		data, err := os.ReadFile(f)
		if err != nil {
			return nil, err
		}
		var bd builtDeck
		if err := json.Unmarshal(data, &bd); err != nil {
			return nil, fmt.Errorf("parsing %s: %w", f, err)
		}
		if bd.Deck == "" {
			bd.Deck = slug
		}
		var styles []string
		for _, s := range bd.Styles {
			if a, ok := bd.StyleAvailability[s]; !ok || a.CDN {
				styles = append(styles, s)
			}
		}
		if len(styles) == 0 {
			continue // nothing downloadable; the store would hide it anyway
		}
		added := previous[bd.Deck]
		if added == "" {
			added = today
		}
		cat.Decks = append(cat.Decks, CatalogDeck{
			Slug:         bd.Deck,
			Version:      bd.Version,
			Tier:         bd.Tier,
			Added:        added,
			DefaultStyle: bd.DefaultStyle,
			Styles:       styles,
			Cards:        len(bd.Cards),
			Titles:       bd.Titles,
		})
	}
	sort.Slice(cat.Decks, func(i, j int) bool { return cat.Decks[i].Slug < cat.Decks[j].Slug })
	return cat, nil
}

// previousAdded maps slug → added date from an earlier catalog, if any.
func previousAdded(path string) map[string]string {
	out := map[string]string{}
	if path == "" {
		return out
	}
	raw, err := os.ReadFile(path)
	if err != nil {
		return out
	}
	var prev RemoteCatalog
	if json.Unmarshal(raw, &prev) != nil {
		return out
	}
	for _, d := range prev.Decks {
		if _, err := time.Parse("2006-01-02", d.Added); err == nil {
			out[d.Slug] = d.Added
		}
	}
	return out
}

// Marshal renders the catalog as indented JSON with a trailing newline.
func (c *RemoteCatalog) Marshal() ([]byte, error) {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", "  ")
	if err := enc.Encode(c); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// WriteRemoteCatalog builds the catalog and writes it to dst, leaving the file
// untouched when the content is identical. Reports whether it wrote.
func WriteRemoteCatalog(dst string, opts CatalogOptions) (bool, error) {
	if opts.Previous == "" {
		opts.Previous = dst
	}
	cat, err := BuildRemoteCatalog(opts)
	if err != nil {
		return false, err
	}
	data, err := cat.Marshal()
	if err != nil {
		return false, err
	}
	if old, err := os.ReadFile(dst); err == nil && bytes.Equal(old, data) {
		return false, nil
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return false, err
	}
	tmp := dst + ".tmp"
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return false, err
	}
	return true, os.Rename(tmp, dst)
}

func nonNil(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}
