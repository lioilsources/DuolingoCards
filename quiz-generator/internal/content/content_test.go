package content

import (
	"os"
	"path/filepath"
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
	return dir
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
