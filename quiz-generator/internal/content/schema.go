// Package content models the on-disk, deck-per-folder authoring format and the
// runtime deck.json build output for the no-backend pipeline.
//
// Authoring layout (one folder per deck, versioned in Git):
//
//	decks/<slug>/
//	  deck.yaml            meta + cards (language-neutral: key, hint, visual brief)
//	  i18n/<lang>.yaml     label + summary + info for every card, one file per language
//	  images/<style>/*.webp generated images, keyed by (concept, style)
//
// YAML is the human-authored source; deck.json is the merged build output that
// ships in the app binary.
package content

// DeckYAML is decks/<slug>/deck.yaml — the language-neutral spine of a deck.
type DeckYAML struct {
	Slug         string     `yaml:"slug"`
	Version      int        `yaml:"version"`
	Styles       []string   `yaml:"styles"`        // named image style configs, e.g. flux-real, pony-cartoon
	DefaultStyle string     `yaml:"default_style"` // style used at runtime when no override
	Tier         int        `yaml:"tier"`          // localization tier 0-3 (see plan §8)
	BriefAttrs   []string   `yaml:"brief_attrs"`   // extra attrs merged into every card's brief (e.g. feral, cute)
	Cards        []CardYAML `yaml:"cards"`
}

// CardYAML is one concept in deck.yaml. It carries no display text — only the
// stable key, an authoring hint for disambiguation, the image filename, and the
// language-neutral visual brief used to drive image generation.
type CardYAML struct {
	Key   string      `yaml:"key"`   // stable concept key, e.g. animal.lion
	Hint  string      `yaml:"hint"`  // disambiguation note for translators (not shown)
	Image string      `yaml:"image"` // image filename within images/<style>/
	Brief VisualBrief `yaml:"brief"`
}

// VisualBrief is a semantic, backend-agnostic description of the image. The
// prompt package expands it into FLUX and Pony prompts (dual prompting), so the
// brief is authored once per concept rather than as two hand-written prompts.
type VisualBrief struct {
	Subject string   `yaml:"subject"` // main thing, e.g. "lion"
	Attrs   []string `yaml:"attrs"`   // adjectives/poses, e.g. ["friendly","sitting"]
	Setting []string `yaml:"setting"` // background tags, e.g. ["savanna","grass","golden hour"]
	Avoid   []string `yaml:"avoid"`   // things to keep out, e.g. ["text","blood"]
}

// I18nFile is decks/<slug>/i18n/<lang>.yaml — all display text for one language.
type I18nFile struct {
	Lang  string                 `yaml:"lang"`  // BCP-47 code, must match file name
	Pivot bool                   `yaml:"pivot"` // true for the fact-checked source language
	Title string                 `yaml:"title"` // deck title in this language
	Cards map[string]CardI18n    `yaml:"cards"` // keyed by concept key
	Extra map[string]interface{} `yaml:"extra,omitempty"`
}

// CardI18n is the three learning fields for one concept in one language.
//
//	label   — the word/translation
//	summary — 1-2 sentence gloss, shown on the FOREIGN-language side
//	info    — full learning text, shown on the NATIVE-language side
//
// summary and info are factual statements: per the plan they are authored and
// fact-checked once in the pivot language, then translated. label is translated
// independently (single word, disambiguated via CardYAML.Hint).
type CardI18n struct {
	Label   string `yaml:"label"`
	Summary string `yaml:"summary"`
	Info    string `yaml:"info"`
}

// ---- Build output (deck.json) ----

// RuntimeDeck is the merged build artifact shipped in the app binary.
type RuntimeDeck struct {
	Deck    string `json:"deck"`
	Version int    `json:"version"`
	Tier    int    `json:"tier,omitempty"`
	// Styles are the styles whose images actually exist in this repo, derived
	// from disk rather than copied from deck.yaml — see availability.go.
	Styles []string `json:"styles"`
	// StyleAvailability says, per style in Styles, how the images reach the
	// app. Older app builds ignore this field and fall back to Styles, which
	// is why Styles stays a plain string list.
	StyleAvailability map[string]StyleAvailability `json:"styleAvailability,omitempty"`
	DefaultStyle      string                       `json:"defaultStyle"`
	Titles            map[string]string            `json:"titles"` // lang → deck title
	Cards             []RuntimeCard                `json:"cards"`
}

// RuntimeCard is one concept with all languages folded into per-field maps.
type RuntimeCard struct {
	Key     string            `json:"key"`
	Image   string            `json:"image"`
	Label   map[string]string `json:"label"`   // lang → label
	Summary map[string]string `json:"summary"` // lang → summary
	Info    map[string]string `json:"info"`    // lang → info
}
