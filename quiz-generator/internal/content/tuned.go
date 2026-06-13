package content

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// TunedEntry is the winning prompt for one card in one style, as produced by the
// iterative image-tuning loop. It is the exact prompt + seed that generated the
// saved image, recorded so the result is reproducible and so `images` can reuse
// it instead of re-expanding the brief.
type TunedEntry struct {
	Positive  string  `yaml:"positive"`
	Negative  string  `yaml:"negative,omitempty"`
	Seed      int64   `yaml:"seed"`
	Score     float64 `yaml:"score,omitempty"`
	Model     string  `yaml:"model,omitempty"` // builder model that authored the prompt
	Iters     int     `yaml:"iters,omitempty"` // iterations it took to reach this prompt
	UpdatedAt string  `yaml:"updated_at,omitempty"`
}

// tunedFile is the on-disk shape of decks/<slug>/tuned/<style>.yaml.
type tunedFile struct {
	Style string                `yaml:"style"`
	Cards map[string]TunedEntry `yaml:"cards"`
}

// tunedDir is the per-deck folder holding tuning sidecars and transcripts.
func tunedDir(deckDir string) string { return filepath.Join(deckDir, "tuned") }

// tunedPath is decks/<slug>/tuned/<style>.yaml.
func tunedPath(deckDir, style string) string {
	return filepath.Join(tunedDir(deckDir), style+".yaml")
}

// LoadTuned reads the tuning sidecar for a (deck, style). A missing file is not
// an error — it returns an empty map.
func LoadTuned(deckDir, style string) (map[string]TunedEntry, error) {
	raw, err := os.ReadFile(tunedPath(deckDir, style))
	if err != nil {
		if os.IsNotExist(err) {
			return map[string]TunedEntry{}, nil
		}
		return nil, fmt.Errorf("reading tuned sidecar: %w", err)
	}
	var f tunedFile
	if err := yaml.Unmarshal(raw, &f); err != nil {
		return nil, fmt.Errorf("parsing tuned sidecar: %w", err)
	}
	if f.Cards == nil {
		f.Cards = map[string]TunedEntry{}
	}
	return f.Cards, nil
}

// SaveTuned upserts one card's tuned prompt into the sidecar, preserving every
// other card. It writes the whole file atomically (temp + rename). Callers that
// run concurrently must serialize SaveTuned for the same (deck, style) — the
// read-modify-write is not internally locked.
func SaveTuned(deckDir, style, key string, entry TunedEntry) error {
	cards, err := LoadTuned(deckDir, style)
	if err != nil {
		return err
	}
	cards[key] = entry

	out := tunedFile{Style: style, Cards: cards}
	data, err := yaml.Marshal(out)
	if err != nil {
		return fmt.Errorf("marshal tuned sidecar: %w", err)
	}

	dir := tunedDir(deckDir)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("create tuned dir: %w", err)
	}
	tmp, err := os.CreateTemp(dir, "."+style+".*.tmp")
	if err != nil {
		return fmt.Errorf("create temp sidecar: %w", err)
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName) // no-op once renamed
	if _, err := tmp.Write(data); err != nil {
		tmp.Close()
		return fmt.Errorf("write temp sidecar: %w", err)
	}
	if err := tmp.Close(); err != nil {
		return fmt.Errorf("close temp sidecar: %w", err)
	}
	if err := os.Rename(tmpName, tunedPath(deckDir, style)); err != nil {
		return fmt.Errorf("rename temp sidecar: %w", err)
	}
	return nil
}
