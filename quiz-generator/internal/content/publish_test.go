package content

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

// publishFixture builds a deck with one complete style and one incomplete one.
func publishFixture(t *testing.T) *Deck {
	t.Helper()
	dir := t.TempDir()
	mustWrite(t, filepath.Join(dir, "deck.yaml"), `slug: test-deck
version: 1
styles: [photo, ink]
default_style: photo
cards:
  - {key: a.one,   image: a.one.png,   brief: {subject: one}}
  - {key: a.two,   image: a.two.png,   brief: {subject: two}}
  - {key: a.three, image: a.three.png, brief: {subject: three}}
`)
	mustWrite(t, filepath.Join(dir, "i18n", "cs.yaml"), `lang: cs
pivot: true
title: t
cards:
  a.one: {label: a, summary: s, info: i}
  a.two: {label: b, summary: s, info: i}
  a.three: {label: c, summary: s, info: i}
`)
	writeStyleImages(t, dir, "photo", "a.one.png", "a.two.png", "a.three.png")
	writeStyleImages(t, dir, "ink", "a.one.png") // incomplete on purpose
	d, err := Load(dir)
	if err != nil {
		t.Fatal(err)
	}
	return d
}

func TestPublishCopiesPreviewsAndFullSet(t *testing.T) {
	d := publishFixture(t)
	root := t.TempDir()
	previews := filepath.Join(root, "previews")
	cdn := filepath.Join(root, "cdn")

	res, err := d.Publish(PublishOptions{
		PreviewsDir: previews, CDNDir: cdn, PreviewCards: 2, Images: true,
	})
	if err != nil {
		t.Fatalf("Publish: %v", err)
	}

	if res.Previews["photo"] != 2 {
		t.Errorf("previews = %d, want 2 (preview-cards)", res.Previews["photo"])
	}
	if res.CDN["photo"] != 3 {
		t.Errorf("cdn = %d, want all 3 cards", res.CDN["photo"])
	}
	// The preview set is the leading cards, not an arbitrary subset.
	for _, name := range []string{"a.one.png", "a.two.png"} {
		if _, err := os.Stat(filepath.Join(previews, "test-deck", "photo", name)); err != nil {
			t.Errorf("preview %s missing: %v", name, err)
		}
	}
	if _, err := os.Stat(filepath.Join(previews, "test-deck", "photo", "a.three.png")); err == nil {
		t.Error("a.three.png should be past the preview cutoff")
	}
}

// An incomplete style must not be published: publishing it would make it look
// deliverable to Build, and the store would offer a style missing most cards.
func TestPublishSkipsIncompleteStyles(t *testing.T) {
	d := publishFixture(t)
	root := t.TempDir()

	res, err := d.Publish(PublishOptions{
		PreviewsDir:  filepath.Join(root, "previews"),
		CDNDir:       filepath.Join(root, "cdn"),
		PreviewCards: 3, Images: true,
	})
	if err != nil {
		t.Fatalf("Publish: %v", err)
	}
	if n, ok := res.CDN["ink"]; ok && n > 0 {
		t.Errorf("incomplete style was published (%d files)", n)
	}
	if _, err := os.Stat(filepath.Join(root, "cdn", "test-deck", "images", "ink")); err == nil {
		t.Error("incomplete style got a CDN directory")
	}
}

// Publishing then building must agree: whatever reached the trees is exactly
// what Build marks offerable.
func TestPublishThenBuildAgree(t *testing.T) {
	d := publishFixture(t)
	root := t.TempDir()
	mustWrite(t, filepath.Join(root, "pubspec.yaml"), "flutter:\n  assets: []\n")

	if _, err := d.Publish(PublishOptions{
		PreviewsDir:  filepath.Join(root, "assets", "previews"),
		CDNDir:       filepath.Join(root, "docs", "decks"),
		PreviewCards: 3, Images: true,
	}); err != nil {
		t.Fatalf("Publish: %v", err)
	}

	rd := d.BuildFor(AppLayout{Root: root})
	got, ok := rd.StyleAvailability["photo"]
	if !ok {
		t.Fatal("photo missing from StyleAvailability")
	}
	if !got.Bundled || !got.CDN {
		t.Errorf("photo = %+v, want bundled and cdn after publishing both", got)
	}
	if _, ok := rd.StyleAvailability["ink"]; ok {
		t.Error("incomplete style leaked into the built deck")
	}
}

// Re-publishing an unchanged tree must not rewrite files, or every publish
// churns the Git working tree with identical bytes.
func TestPublishIsIdempotent(t *testing.T) {
	d := publishFixture(t)
	root := t.TempDir()
	opts := PublishOptions{CDNDir: filepath.Join(root, "cdn"), PreviewCards: 0, Images: true}

	if _, err := d.Publish(opts); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(root, "cdn", "test-deck", "images", "photo", "a.one.png")
	first, err := os.Stat(target)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := d.Publish(opts); err != nil {
		t.Fatal(err)
	}
	second, err := os.Stat(target)
	if err != nil {
		t.Fatal(err)
	}
	if !second.ModTime().Equal(first.ModTime()) {
		t.Error("unchanged file was rewritten on re-publish")
	}
}

// WebP publishing must keep deck.json and disk in agreement: publish writes
// .webp, so Build has to name .webp. A mismatch is invisible until the app
// requests a file that was never written.
func TestWebPPublishAndBuildAgreeOnNames(t *testing.T) {
	if _, err := exec.LookPath("cwebp"); err != nil {
		t.Skip("cwebp not installed")
	}
	d := publishFixture(t)
	root := t.TempDir()
	mustWrite(t, filepath.Join(root, "pubspec.yaml"), "flutter:\n  assets: []\n")

	if _, err := d.Publish(PublishOptions{
		PreviewsDir:  filepath.Join(root, "assets", "previews"),
		CDNDir:       filepath.Join(root, "docs", "decks"),
		PreviewCards: 3, Images: true, WebPQuality: 85,
	}); err != nil {
		t.Fatalf("Publish: %v", err)
	}

	rd := d.BuildFor(AppLayout{Root: root}.WebPImages(true))
	for _, c := range rd.Cards {
		if filepath.Ext(c.Image) != ".webp" {
			t.Fatalf("deck.json still names %q", c.Image)
		}
		p := filepath.Join(root, "docs", "decks", "test-deck", "images", "photo", c.Image)
		if _, err := os.Stat(p); err != nil {
			t.Errorf("deck.json names %s but it was not published: %v", c.Image, err)
		}
	}
	// The PNG masters must be untouched — only what ships is re-encoded.
	if _, err := os.Stat(filepath.Join(d.Dir, "images", "photo", "a.one.png")); err != nil {
		t.Errorf("master PNG disturbed: %v", err)
	}
}

// Without WebP the names stay as authored, so an existing PNG deployment keeps
// working.
func TestBuildKeepsPNGNamesByDefault(t *testing.T) {
	d := publishFixture(t)
	rd := d.Build()
	if filepath.Ext(rd.Cards[0].Image) != ".png" {
		t.Fatalf("default build renamed image to %q", rd.Cards[0].Image)
	}
}
