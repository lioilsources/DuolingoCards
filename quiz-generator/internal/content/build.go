package content

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"

	"github.com/duolingocards/quiz-generator/internal/langs"
)

// Build merges a loaded deck (deck.yaml + i18n/*.yaml) into the runtime
// deck.json structure. Only supported languages (the pivot plus Gold-flagged
// targets — see langs.SupportedSet) are emitted; long-tail translations remain
// in the source tree but are not shipped. Missing translations for supported
// languages are simply omitted from the per-field maps — run Lint first to
// guarantee completeness.
func (d *Deck) Build() *RuntimeDeck {
	supported := langs.SupportedSet()
	out := &RuntimeDeck{
		Deck:         d.Meta.Slug,
		Version:      d.Meta.Version,
		Tier:         d.Meta.Tier,
		Styles:       d.Meta.Styles,
		DefaultStyle: d.Meta.DefaultStyle,
		Titles:       map[string]string{},
		Cards:        make([]RuntimeCard, 0, len(d.Meta.Cards)),
	}
	if out.DefaultStyle == "" && len(out.Styles) > 0 {
		out.DefaultStyle = out.Styles[0]
	}

	for _, lang := range d.Langs {
		if !supported[lang] {
			continue
		}
		if f := d.I18n[lang]; f != nil && f.Title != "" {
			out.Titles[lang] = f.Title
		}
	}

	for _, c := range d.Meta.Cards {
		rc := RuntimeCard{
			Key:     c.Key,
			Image:   c.Image,
			Label:   map[string]string{},
			Summary: map[string]string{},
			Info:    map[string]string{},
		}
		for _, lang := range d.Langs {
			if !supported[lang] {
				continue
			}
			f := d.I18n[lang]
			if f == nil {
				continue
			}
			ci, ok := f.Cards[c.Key]
			if !ok {
				continue
			}
			if ci.Label != "" {
				rc.Label[lang] = ci.Label
			}
			if ci.Summary != "" {
				rc.Summary[lang] = ci.Summary
			}
			if ci.Info != "" {
				rc.Info[lang] = ci.Info
			}
		}
		out.Cards = append(out.Cards, rc)
	}
	return out
}

// SaveJSON writes the runtime deck to <outputDir>/<slug>.json with stable,
// indented formatting (map keys sorted for deterministic diffs).
func (rd *RuntimeDeck) SaveJSON(outputDir string) (string, error) {
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return "", fmt.Errorf("creating output dir: %w", err)
	}
	path := filepath.Join(outputDir, rd.Deck+".json")

	// json.Marshal already sorts map keys, giving deterministic output.
	data, err := json.MarshalIndent(rd, "", "  ")
	if err != nil {
		return "", fmt.Errorf("encoding deck: %w", err)
	}
	if err := os.WriteFile(path, append(data, '\n'), 0644); err != nil {
		return "", fmt.Errorf("writing %s: %w", path, err)
	}
	return path, nil
}

// CardKeys returns the deck's concept keys in authoring order.
func (d *Deck) CardKeys() []string {
	keys := make([]string, len(d.Meta.Cards))
	for i, c := range d.Meta.Cards {
		keys[i] = c.Key
	}
	return keys
}

// SortedI18nLangs returns i18n languages sorted with the pivot first.
func (d *Deck) SortedI18nLangs() []string {
	pivot := d.PivotLang()
	langs := append([]string{}, d.Langs...)
	sort.Slice(langs, func(i, j int) bool {
		if langs[i] == pivot {
			return true
		}
		if langs[j] == pivot {
			return false
		}
		return langs[i] < langs[j]
	})
	return langs
}
