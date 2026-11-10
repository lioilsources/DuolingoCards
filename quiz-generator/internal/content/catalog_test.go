package content

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"
)

type catalogFixture struct {
	source, built, cdn, dst string
}

func newCatalogFixture(t *testing.T) catalogFixture {
	t.Helper()
	root := t.TempDir()
	f := catalogFixture{
		source: filepath.Join(root, "catalog.json"),
		built:  filepath.Join(root, "built"),
		cdn:    filepath.Join(root, "cdn"),
		dst:    filepath.Join(root, "out", "catalog.json"),
	}
	mustWrite(t, f.source, `{
  "_comment": "dropped from the remote copy",
  "free": ["alpha"],
  "products": [{"code": "deck.beta", "sku": {"apple": "x.beta", "google": "x.beta"}, "unlocks": ["beta"]}]
}`)
	f.addDeck(t, "alpha", 0, true, `{"photo": {"bundled": true, "cdn": true}}`)
	f.addDeck(t, "beta", 1, true, `{"photo": {"bundled": false, "cdn": true}, "ink": {"bundled": true, "cdn": false}}`)
	// Built but never published: the CDN cannot serve it.
	f.addDeck(t, "gamma", 1, false, `{"photo": {"bundled": true, "cdn": false}}`)
	return f
}

func (f catalogFixture) addDeck(t *testing.T, slug string, tier int, published bool, avail string) {
	t.Helper()
	body := `{"deck": "` + slug + `", "version": 2, "tier": ` + itoa(tier) + `,
  "styles": ["photo", "ink"], "styleAvailability": ` + avail + `,
  "defaultStyle": "photo", "titles": {"en": "` + slug + ` en", "cs": "` + slug + ` cs"},
  "cards": [{"key": "a"}, {"key": "b"}]}`
	mustWrite(t, filepath.Join(f.built, slug+".json"), body)
	if published {
		mustWrite(t, filepath.Join(f.cdn, slug, "deck.json"), body)
	}
}

func itoa(i int) string {
	b, _ := json.Marshal(i)
	return string(b)
}

func (f catalogFixture) opts(today string) CatalogOptions {
	d, _ := time.Parse("2006-01-02", today)
	return CatalogOptions{Source: f.source, BuiltDir: f.built, CDNDir: f.cdn, Today: d}
}

func TestBuildRemoteCatalogIndexesPublishedDecks(t *testing.T) {
	f := newCatalogFixture(t)
	cat, err := BuildRemoteCatalog(f.opts("2026-11-01"))
	if err != nil {
		t.Fatal(err)
	}
	if len(cat.Free) != 1 || cat.Free[0] != "alpha" {
		t.Errorf("free = %v", cat.Free)
	}
	if len(cat.Products) != 1 {
		t.Errorf("products = %d, want 1", len(cat.Products))
	}
	if len(cat.Decks) != 2 {
		t.Fatalf("decks = %+v, want alpha+beta (gamma unpublished)", cat.Decks)
	}
	beta := cat.Decks[1]
	if beta.Slug != "beta" || beta.Tier != 1 || beta.Version != 2 || beta.Cards != 2 {
		t.Errorf("beta = %+v", beta)
	}
	if len(beta.Styles) != 1 || beta.Styles[0] != "photo" {
		t.Errorf("beta styles = %v, want only the CDN one", beta.Styles)
	}
	if beta.Added != "2026-11-01" || beta.Titles["cs"] != "beta cs" {
		t.Errorf("beta = %+v", beta)
	}
}

func TestWriteRemoteCatalogKeepsAddedAndDoesNotChurn(t *testing.T) {
	f := newCatalogFixture(t)
	wrote, err := WriteRemoteCatalog(f.dst, f.opts("2026-11-01"))
	if err != nil || !wrote {
		t.Fatalf("first write: wrote=%v err=%v", wrote, err)
	}
	first, _ := os.ReadFile(f.dst)

	// A later run with nothing new must leave the file byte-identical, even
	// though "today" moved on.
	wrote, err = WriteRemoteCatalog(f.dst, f.opts("2026-11-09"))
	if err != nil || wrote {
		t.Fatalf("second write: wrote=%v err=%v, want no write", wrote, err)
	}
	again, _ := os.ReadFile(f.dst)
	if string(again) != string(first) {
		t.Error("catalog changed without any new deck")
	}

	// Publishing a new deck stamps only that deck with the new date.
	f.addDeck(t, "delta", 1, true, `{"photo": {"bundled": false, "cdn": true}}`)
	if _, err := WriteRemoteCatalog(f.dst, f.opts("2026-11-09")); err != nil {
		t.Fatal(err)
	}
	var cat RemoteCatalog
	raw, _ := os.ReadFile(f.dst)
	if err := json.Unmarshal(raw, &cat); err != nil {
		t.Fatal(err)
	}
	added := map[string]string{}
	for _, d := range cat.Decks {
		added[d.Slug] = d.Added
	}
	if added["alpha"] != "2026-11-01" || added["delta"] != "2026-11-09" {
		t.Errorf("added = %v", added)
	}
}

func TestBuildRemoteCatalogMissingSource(t *testing.T) {
	f := newCatalogFixture(t)
	opts := f.opts("2026-11-01")
	opts.Source = filepath.Join(t.TempDir(), "nope.json")
	if _, err := BuildRemoteCatalog(opts); err == nil {
		t.Error("want an error for a missing source catalog")
	}
}
