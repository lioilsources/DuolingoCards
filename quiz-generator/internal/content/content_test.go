package content

import (
	"image"
	"image/png"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// writeDeck creates a minimal deck folder on disk for testing.
func writeDeck(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	deckYAML := `slug: test-deck
version: 2
tier: 0
styles: [flux-real]
default_style: flux-real
cards:
  - key: a.one
    image: a.one.webp
    brief:
      subject: thing one
  - key: a.two
    image: a.two.webp
    brief:
      subject: thing two
`
	csYAML := `lang: cs
pivot: true
title: Testovaci
cards:
  a.one:
    label: jedna
    summary: shrnuti jedna
    info: info jedna
  a.two:
    label: dva
    summary: shrnuti dva
    info: info dva
`
	enYAML := `lang: en
title: Test deck
cards:
  a.one:
    label: one
    summary: summary one
    info: info one
  a.two:
    label: two
    summary: summary two
    info: info two
`
	mustWrite(t, filepath.Join(dir, "deck.yaml"), deckYAML)
	mustWrite(t, filepath.Join(dir, "i18n", "cs.yaml"), csYAML)
	mustWrite(t, filepath.Join(dir, "i18n", "en.yaml"), enYAML)
	// Build derives the shipped style list from the images on disk, so a deck
	// fixture without image files would ship no styles at all.
	writeStyleImages(t, dir, "flux-real", "a.one.webp", "a.two.webp")
	return dir
}

// writeStyleImages creates placeholder image files under images/<style>/.
// They are real PNGs, not stub bytes: the WebP publish path shells out to
// cwebp, which rejects anything that is not a decodable image.
func writeStyleImages(t *testing.T, deckDir, style string, names ...string) {
	t.Helper()
	for _, n := range names {
		path := filepath.Join(deckDir, "images", style, n)
		if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
			t.Fatal(err)
		}
		f, err := os.Create(path)
		if err != nil {
			t.Fatal(err)
		}
		img := image.NewRGBA(image.Rect(0, 0, 4, 4))
		for i := range img.Pix {
			img.Pix[i] = uint8(i * 7)
		}
		if err := png.Encode(f, img); err != nil {
			t.Fatal(err)
		}
		if err := f.Close(); err != nil {
			t.Fatal(err)
		}
	}
}

func mustWrite(t *testing.T, path, content string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}
}

func TestLoadAndBuild(t *testing.T) {
	dir := writeDeck(t)
	d, err := Load(dir)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if d.Meta.Slug != "test-deck" || d.Meta.Version != 2 {
		t.Fatalf("unexpected meta: %+v", d.Meta)
	}
	if got := d.PivotLang(); got != "cs" {
		t.Fatalf("PivotLang = %q, want cs", got)
	}
	if len(d.Langs) != 2 {
		t.Fatalf("Langs = %v, want 2", d.Langs)
	}

	rd := d.Build()
	if rd.DefaultStyle != "flux-real" {
		t.Fatalf("DefaultStyle = %q", rd.DefaultStyle)
	}
	if len(rd.Cards) != 2 {
		t.Fatalf("cards = %d, want 2", len(rd.Cards))
	}
	c0 := rd.Cards[0]
	if c0.Label["en"] != "one" || c0.Label["cs"] != "jedna" {
		t.Fatalf("label map wrong: %+v", c0.Label)
	}
	if c0.Summary["en"] != "summary one" || c0.Info["cs"] != "info jedna" {
		t.Fatalf("summary/info map wrong: %+v %+v", c0.Summary, c0.Info)
	}
	if rd.Titles["en"] != "Test deck" || rd.Titles["cs"] != "Testovaci" {
		t.Fatalf("titles wrong: %+v", rd.Titles)
	}
}

// A fully-translated deck (for the two languages present) should produce no
// errors when not in strict mode.
func TestLintClean(t *testing.T) {
	dir := writeDeck(t)
	d, _ := Load(dir)
	issues := d.Lint(LintOptions{})
	if HasErrors(issues) {
		t.Fatalf("expected no errors, got: %v", issues)
	}
}

// Strict mode flags the 18 missing target languages as errors.
func TestLintStrictMissingTargets(t *testing.T) {
	dir := writeDeck(t)
	d, _ := Load(dir)
	issues := d.Lint(LintOptions{RequireAllTargets: true})
	if !HasErrors(issues) {
		t.Fatal("expected errors for missing target languages in strict mode")
	}
}

// An orphan translation key (not in deck.yaml) is always an error.
func TestLintOrphanKey(t *testing.T) {
	dir := writeDeck(t)
	mustWrite(t, filepath.Join(dir, "i18n", "en.yaml"), `lang: en
title: Test deck
cards:
  a.one: {label: one, summary: s, info: i}
  a.two: {label: two, summary: s, info: i}
  a.ghost: {label: ghost, summary: s, info: i}
`)
	d, _ := Load(dir)
	issues := d.Lint(LintOptions{})
	if !HasErrors(issues) {
		t.Fatal("expected error for orphan key a.ghost")
	}
}

// deck.yaml declares intent; only styles with a complete image set ship. A
// style with no images at all, and one rendered for some cards but not all,
// must both stay out of deck.json.
func TestBuildShipsOnlyCompleteStyles(t *testing.T) {
	dir := writeDeck(t)
	mustWrite(t, filepath.Join(dir, "deck.yaml"), `slug: test-deck
version: 2
styles: [flux-real, pony-cartoon, illustrious-flat]
default_style: pony-cartoon
cards:
  - {key: a.one, image: a.one.webp, brief: {subject: one}}
  - {key: a.two, image: a.two.webp, brief: {subject: two}}
`)
	// flux-real complete (from writeDeck), illustrious-flat partial, pony-cartoon absent.
	writeStyleImages(t, dir, "illustrious-flat", "a.one.webp")

	d, err := Load(dir)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	rd := d.Build()
	if len(rd.Styles) != 1 || rd.Styles[0] != "flux-real" {
		t.Fatalf("Styles = %v, want [flux-real]", rd.Styles)
	}
	// default_style named a style that does not ship; it must fall back rather
	// than leave the app pointing at an empty image directory.
	if rd.DefaultStyle != "flux-real" {
		t.Fatalf("DefaultStyle = %q, want flux-real", rd.DefaultStyle)
	}

	issues := d.Lint(LintOptions{})
	var warned int
	for _, is := range issues {
		if is.Severity == Warn && (strings.Contains(is.Message, `style "pony-cartoon"`) ||
			strings.Contains(is.Message, `style "illustrious-flat"`)) {
			warned++
		}
	}
	if warned != 2 {
		t.Fatalf("expected a warning for each undeliverable style, got %d in %v", warned, issues)
	}
}

// Availability is what lets the store hide a style it cannot render: images in
// the repo are not the same thing as images on a phone.
func TestBuildRecordsDelivery(t *testing.T) {
	deckDir := writeDeck(t)
	writeStyleImages(t, deckDir, "pony-cartoon", "a.one.webp", "a.two.webp")
	mustWrite(t, filepath.Join(deckDir, "deck.yaml"), `slug: test-deck
version: 2
styles: [flux-real, pony-cartoon]
default_style: flux-real
cards:
  - {key: a.one, image: a.one.webp, brief: {subject: one}}
  - {key: a.two, image: a.two.webp, brief: {subject: two}}
`)

	// An app tree where flux-real has a bundled preview and pony-cartoon has
	// neither a preview nor a CDN publish.
	root := t.TempDir()
	mustWrite(t, filepath.Join(root, "pubspec.yaml"), "flutter:\n  assets:\n    - assets/previews/test-deck/flux-real/\n")
	mustWrite(t, filepath.Join(root, "assets", "previews", "test-deck", "flux-real", "a.one.webp"), "png")

	d, _ := Load(deckDir)
	rd := d.BuildFor(AppLayout{Root: root})

	if len(rd.Styles) != 2 {
		t.Fatalf("Styles = %v, want both (images exist for both)", rd.Styles)
	}
	if got := rd.StyleAvailability["flux-real"]; !got.Bundled || got.CDN || !got.Offerable() {
		t.Fatalf("flux-real availability = %+v, want bundled only", got)
	}
	if got := rd.StyleAvailability["pony-cartoon"]; got.Offerable() {
		t.Fatalf("pony-cartoon availability = %+v, want unreachable", got)
	}

	// Publishing it to the CDN tree makes it offerable without bundling.
	mustWrite(t, filepath.Join(root, "docs", "decks", "test-deck", "images", "pony-cartoon", "a.one.webp"), "png")
	rd = d.BuildFor(AppLayout{Root: root})
	if got := rd.StyleAvailability["pony-cartoon"]; !got.CDN || got.Bundled || !got.Offerable() {
		t.Fatalf("pony-cartoon availability = %+v, want cdn only", got)
	}
}

// A full image set listed in pubspec.yaml counts as bundled (the colors-basic
// pilot ships this way), but only when the directory actually holds files.
func TestBundledFullImagesRequireFiles(t *testing.T) {
	root := t.TempDir()
	mustWrite(t, filepath.Join(root, "pubspec.yaml"), "flutter:\n  assets:\n    - decks/colors-basic/images/flux-real/\n")
	app := AppLayout{Root: root}

	if got := app.Availability("colors-basic", "flux-real"); got.Bundled {
		t.Fatalf("stale pubspec entry with no files counted as bundled: %+v", got)
	}
	mustWrite(t, filepath.Join(root, "decks", "colors-basic", "images", "flux-real", "red.webp"), "png")
	if got := app.Availability("colors-basic", "flux-real"); !got.Bundled {
		t.Fatalf("pubspec-listed full image set not counted as bundled: %+v", got)
	}
}

// Duplicate keys in deck.yaml are an error.
func TestLintDuplicateKey(t *testing.T) {
	dir := t.TempDir()
	mustWrite(t, filepath.Join(dir, "deck.yaml"), `slug: dup
styles: [flux-real]
default_style: flux-real
cards:
  - {key: a.x, image: x.webp, brief: {subject: x}}
  - {key: a.x, image: x.webp, brief: {subject: x}}
`)
	mustWrite(t, filepath.Join(dir, "i18n", "cs.yaml"), `lang: cs
pivot: true
title: t
cards:
  a.x: {label: x, summary: s, info: i}
`)
	d, _ := Load(dir)
	issues := d.Lint(LintOptions{})
	if !HasErrors(issues) {
		t.Fatal("expected error for duplicate key")
	}
}
