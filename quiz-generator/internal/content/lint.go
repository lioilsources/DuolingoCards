package content

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/duolingocards/quiz-generator/internal/langs"
)

// Severity of a lint finding.
type Severity int

const (
	// Warn is advisory: the deck still builds (e.g. an image file is missing
	// because binaries live outside the text repo, or a non-target language
	// is present).
	Warn Severity = iota
	// Error blocks a valid build (e.g. a card has no key, a translation is
	// missing for a target language).
	Error
)

func (s Severity) String() string {
	if s == Error {
		return "error"
	}
	return "warn"
}

// Issue is a single lint finding.
type Issue struct {
	Severity Severity
	Deck     string
	Message  string
}

func (i Issue) String() string {
	return fmt.Sprintf("[%s] %s: %s", i.Severity, i.Deck, i.Message)
}

// LintOptions tunes which checks are fatal.
type LintOptions struct {
	// RequireAllTargets makes a missing target-language i18n file or a missing
	// per-card translation an Error. When false they are Warnings (useful while
	// a deck is still being translated).
	RequireAllTargets bool
	// CheckImages verifies each card image exists under images/<defaultStyle>/.
	// Missing images are Warnings (binaries may be synced separately).
	CheckImages bool
}

// Lint validates a loaded deck. The set of checks stands in for the database
// constraints we no longer have: every card has a key+image+brief, no orphan
// translation keys, every target language covers every card, schema is sane.
func (d *Deck) Lint(opts LintOptions) []Issue {
	var issues []Issue
	add := func(sev Severity, format string, args ...interface{}) {
		issues = append(issues, Issue{Severity: sev, Deck: d.Meta.Slug, Message: fmt.Sprintf(format, args...)})
	}

	if d.Meta.Slug == "" {
		add(Error, "deck.yaml is missing 'slug'")
	}
	if len(d.Meta.Styles) == 0 {
		add(Warn, "deck.yaml lists no styles")
	}
	if d.Meta.DefaultStyle != "" && !contains(d.Meta.Styles, d.Meta.DefaultStyle) {
		add(Error, "default_style %q is not in styles %v", d.Meta.DefaultStyle, d.Meta.Styles)
	}

	// A declared style with no complete image set never reaches deck.json, so
	// say so here rather than letting the style silently vanish from the store.
	for _, s := range d.Meta.Styles {
		switch have, want := d.StyleImageCoverage(s); {
		case want == 0:
			// No card declares an image at all; the per-card check below covers it.
		case have == 0:
			add(Warn, "style %q is declared but has no images; it will not ship", s)
		case have < want:
			add(Warn, "style %q has only %d/%d images; it will not ship until complete", s, have, want)
		}
	}

	// Card spine checks + duplicate keys.
	seen := map[string]bool{}
	for i, c := range d.Meta.Cards {
		where := fmt.Sprintf("card #%d", i+1)
		if c.Key == "" {
			add(Error, "%s has no key", where)
			continue
		}
		where = "card " + c.Key
		if seen[c.Key] {
			add(Error, "%s: duplicate key", where)
		}
		seen[c.Key] = true
		if c.Image == "" {
			add(Warn, "%s: no image filename", where)
		}
		if c.Brief.Subject == "" {
			add(Warn, "%s: visual brief has no subject", where)
		}
		if opts.CheckImages && c.Image != "" && d.Meta.DefaultStyle != "" {
			p := filepath.Join(d.Dir, "images", d.Meta.DefaultStyle, c.Image)
			if _, err := os.Stat(p); err != nil {
				add(Warn, "%s: image not found at %s", where, p)
			}
		}
	}

	// Pivot presence (facts are authored & fact-checked once in the pivot).
	if d.PivotLang() == "" {
		add(Warn, "no i18n file is flagged as pivot:true (fact-check source)")
	}

	keys := d.CardKeys()

	// Per-language coverage and orphan-key checks.
	missingSev := Warn
	if opts.RequireAllTargets {
		missingSev = Error
	}
	for _, lang := range d.Langs {
		if !langs.IsTarget(lang) && !langs.IsPivot(lang) {
			add(Warn, "i18n/%s.yaml is not one of the %d target languages", lang, len(langs.Targets))
		}
		f := d.I18n[lang]
		if f.Title == "" {
			add(Warn, "i18n/%s.yaml has no deck title", lang)
		}
		for _, key := range keys {
			ci, ok := f.Cards[key]
			if !ok {
				add(missingSev, "i18n/%s.yaml is missing card %q", lang, key)
				continue
			}
			if ci.Label == "" {
				add(missingSev, "i18n/%s.yaml: card %q has empty label", lang, key)
			}
			if ci.Summary == "" {
				add(missingSev, "i18n/%s.yaml: card %q has empty summary", lang, key)
			}
			if ci.Info == "" {
				add(missingSev, "i18n/%s.yaml: card %q has empty info", lang, key)
			}
		}
		// Orphan translation keys (present in i18n but not in deck.yaml).
		for k := range f.Cards {
			if !seen[k] {
				add(Error, "i18n/%s.yaml references unknown card key %q", lang, k)
			}
		}
	}

	// Target languages with no i18n file at all.
	present := map[string]bool{}
	for _, l := range d.Langs {
		present[l] = true
	}
	for _, t := range langs.Targets {
		if !present[t.Code] {
			add(missingSev, "no i18n file for target language %s (%s)", t.Code, t.Name)
		}
	}

	return issues
}

func contains(ss []string, s string) bool {
	for _, v := range ss {
		if v == s {
			return true
		}
	}
	return false
}

// HasErrors reports whether any issue is an Error.
func HasErrors(issues []Issue) bool {
	for _, i := range issues {
		if i.Severity == Error {
			return true
		}
	}
	return false
}
