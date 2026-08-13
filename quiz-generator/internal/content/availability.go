package content

import (
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// A style is only worth offering in the store if two separate things are true,
// and they fail independently:
//
//  1. the images exist in this repo at all (decks/<slug>/images/<style>/), and
//  2. they can reach a phone — either bundled into the app binary or published
//     to the CDN tree the app downloads from.
//
// deck.yaml declares intent, not fact: a deck can list pony-cartoon for months
// before anyone renders it. Build therefore derives the shipped style list from
// disk and records, per style, how it reaches the app.

// StyleAvailability records how one style's images reach the app.
type StyleAvailability struct {
	// Bundled means the images ship inside the app binary — either as a
	// 3-card preview under assets/previews/, or as a full image set listed in
	// pubspec.yaml (the tier-0 pilot decks).
	Bundled bool `json:"bundled"`
	// CDN means the full image set is published under docs/decks/, so the app
	// can download it after unlock.
	CDN bool `json:"cdn"`
}

// Offerable reports whether the store may present this style at all. A style
// that is neither bundled nor published would render placeholders and, on
// unlock, download nothing.
func (a StyleAvailability) Offerable() bool { return a.Bundled || a.CDN }

// AppLayout locates the Flutter trees that decide how a style reaches the app.
// A zero AppLayout probes nothing, which is what the unit tests want.
type AppLayout struct {
	// Root is the repo root holding pubspec.yaml, assets/ and docs/.
	Root string
	// webp mirrors PublishOptions.WebPQuality > 0: when set, Build emits .webp
	// image names. Set it through AppLayout.WebPImages.
	webp bool
}

// StyleImageCoverage counts how many of the deck's cards have an image file on
// disk for style, out of how many cards declare an image at all.
func (d *Deck) StyleImageCoverage(style string) (have, want int) {
	dir := filepath.Join(d.Dir, "images", style)
	for _, c := range d.Meta.Cards {
		if c.Image == "" {
			continue
		}
		want++
		if _, err := os.Stat(filepath.Join(dir, c.Image)); err == nil {
			have++
		}
	}
	return have, want
}

// ImageStyles returns the declared styles whose image set is complete, in
// deck.yaml order. A partially rendered style is excluded: a store chip that
// works for 30 of 50 cards is worse than one that is not offered.
func (d *Deck) ImageStyles() []string {
	var out []string
	for _, s := range d.Meta.Styles {
		have, want := d.StyleImageCoverage(s)
		if want > 0 && have == want {
			out = append(out, s)
		}
	}
	return out
}

// Valid reports whether Root actually points at the Flutter app. Probing a
// wrong directory would mark every style undeliverable and silently empty the
// store, so callers must check this before trusting Availability.
func (l AppLayout) Valid() bool {
	if l.Root == "" {
		return false
	}
	_, err := os.Stat(filepath.Join(l.Root, "pubspec.yaml"))
	return err == nil
}

// Availability probes how the given deck/style reaches the app. With no Root
// configured every style reports as unreachable, so callers that care must
// pass a layout.
func (l AppLayout) Availability(slug, style string) StyleAvailability {
	if l.Root == "" {
		return StyleAvailability{}
	}
	return StyleAvailability{
		Bundled: l.hasPreview(slug, style) || l.bundlesFullImages(slug, style),
		CDN:     hasImages(filepath.Join(l.Root, "docs", "decks", slug, "images", style)),
	}
}

func (l AppLayout) hasPreview(slug, style string) bool {
	return hasImages(filepath.Join(l.Root, "assets", "previews", slug, style))
}

// bundlesFullImages reports whether pubspec.yaml ships the deck's full image
// directory for this style (as colors-basic does). The directory must also be
// non-empty — a stale pubspec entry is not delivery.
func (l AppLayout) bundlesFullImages(slug, style string) bool {
	dir := "decks/" + slug + "/images/" + style
	for _, a := range l.pubspecAssets() {
		if a == dir || a == dir+"/" {
			return hasImages(filepath.Join(l.Root, filepath.FromSlash(dir)))
		}
	}
	return false
}

// pubspecAssets reads flutter.assets from pubspec.yaml. Parse failures yield no
// entries, which downgrades to "not bundled" rather than blocking a build.
func (l AppLayout) pubspecAssets() []string {
	raw, err := os.ReadFile(filepath.Join(l.Root, "pubspec.yaml"))
	if err != nil {
		return nil
	}
	var spec struct {
		Flutter struct {
			Assets []string `yaml:"assets"`
		} `yaml:"flutter"`
	}
	if err := yaml.Unmarshal(raw, &spec); err != nil {
		return nil
	}
	return spec.Flutter.Assets
}

// hasImages reports whether dir exists and holds at least one regular file.
func hasImages(dir string) bool {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return false
	}
	for _, e := range entries {
		if !e.IsDir() {
			return true
		}
	}
	return false
}
