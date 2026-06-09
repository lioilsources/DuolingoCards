package content

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v3"
)

// Deck bundles a parsed deck folder: its spine plus every i18n file, keyed by
// language code.
type Deck struct {
	Dir   string               // folder path on disk
	Meta  DeckYAML             // deck.yaml
	I18n  map[string]*I18nFile // lang code → parsed i18n file
	Langs []string             // i18n languages present, sorted
}

// Load reads decks/<slug>/ (deck.yaml + i18n/*.yaml) into a Deck. It does not
// validate completeness — that is Lint's job.
func Load(dir string) (*Deck, error) {
	metaPath := filepath.Join(dir, "deck.yaml")
	raw, err := os.ReadFile(metaPath)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", metaPath, err)
	}
	var meta DeckYAML
	if err := yaml.Unmarshal(raw, &meta); err != nil {
		return nil, fmt.Errorf("parsing %s: %w", metaPath, err)
	}

	d := &Deck{Dir: dir, Meta: meta, I18n: map[string]*I18nFile{}}

	i18nDir := filepath.Join(dir, "i18n")
	entries, err := os.ReadDir(i18nDir)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", i18nDir, err)
	}
	for _, e := range entries {
		name := e.Name()
		if e.IsDir() || !strings.HasSuffix(name, ".yaml") {
			continue
		}
		path := filepath.Join(i18nDir, name)
		raw, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("reading %s: %w", path, err)
		}
		var f I18nFile
		if err := yaml.Unmarshal(raw, &f); err != nil {
			return nil, fmt.Errorf("parsing %s: %w", path, err)
		}
		code := strings.TrimSuffix(name, ".yaml")
		if f.Lang == "" {
			f.Lang = code
		}
		d.I18n[f.Lang] = &f
		d.Langs = append(d.Langs, f.Lang)
	}
	sort.Strings(d.Langs)
	return d, nil
}

// PivotLang returns the language code flagged as the fact-checked pivot, or ""
// if none is marked.
func (d *Deck) PivotLang() string {
	for _, f := range d.I18n {
		if f.Pivot {
			return f.Lang
		}
	}
	return ""
}

// IsDeckDir reports whether dir looks like a deck folder (has deck.yaml).
func IsDeckDir(dir string) bool {
	_, err := os.Stat(filepath.Join(dir, "deck.yaml"))
	return err == nil
}

// FindDecks returns the deck folders directly under root.
func FindDecks(root string) ([]string, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}
	var dirs []string
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		dir := filepath.Join(root, e.Name())
		if IsDeckDir(dir) {
			dirs = append(dirs, dir)
		}
	}
	sort.Strings(dirs)
	return dirs, nil
}
