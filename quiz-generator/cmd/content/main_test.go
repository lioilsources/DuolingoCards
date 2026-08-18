package main

import (
	"strings"
	"testing"

	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/prompt"
)

func testDeck() *content.Deck {
	return &content.Deck{
		Meta: content.DeckYAML{
			Slug: "food-fruits",
			// Scaffolding that exists to make the FLUX base photographic.
			BriefAttrs: []string{"(vibrant colors:1.3)", "(photorealistic texture:1.1)", "soft studio lighting"},
		},
	}
}

func testCard() content.CardYAML {
	c := content.CardYAML{Key: "fruit.apple", Image: "fruit.apple.png"}
	c.Brief.Subject = "red apple"
	c.Brief.Attrs = []string{"shiny", "round"}
	return c
}

// The text-to-image pass needs the deck's scaffolding: it is what makes the
// base photographic in the first place.
func TestMergedBriefKeepsDeckAttrsForBaseStyle(t *testing.T) {
	b := mergedBrief(testCard(), testDeck(), prompt.StylePhoto)
	joined := strings.Join(b.Attrs, ", ")
	for _, want := range []string{"(vibrant colors:1.3)", "(photorealistic texture:1.1)", "shiny"} {
		if !strings.Contains(joined, want) {
			t.Fatalf("base style lost %q from %q", want, joined)
		}
	}
}

// A restyle must not inherit it: "(vibrant colors:1.3)" fights
// ink's "(monochrome:1.2)", and photoreal tags pull every repaint
// back toward the look of the base.
func TestMergedBriefDropsDeckAttrsForRestyle(t *testing.T) {
	for _, style := range []prompt.Style{
		prompt.StyleInk,
		prompt.StyleIllustriousVanGogh,
		prompt.StylePonyWatercolor,
	} {
		b := mergedBrief(testCard(), testDeck(), style)
		joined := strings.Join(b.Attrs, ", ")
		for _, unwanted := range []string{"vibrant colors", "photorealistic texture", "studio lighting"} {
			if strings.Contains(joined, unwanted) {
				t.Errorf("%s inherited deck scaffolding %q: %q", style.Name, unwanted, joined)
			}
		}
		// The card's own attributes still describe the concept and must survive.
		if !strings.Contains(joined, "shiny") {
			t.Errorf("%s lost the card's own attrs: %q", style.Name, joined)
		}
	}
}

func TestBriefForRejectsUnknownStyle(t *testing.T) {
	if _, _, err := briefFor(testCard(), testDeck(), "does-not-exist"); err == nil {
		t.Fatal("expected an error for an unknown style")
	}
}

// Every style the pipeline can render needs a distinct filename alias, or two
// styles collide in ComfyUI's output directory.
func TestImageFilenamePrefixAliasesAreUnique(t *testing.T) {
	seen := map[string]string{}
	for name := range prompt.DefaultStyles {
		got := imageFilenamePrefix("deck", "ns.card", name)
		if prev, dup := seen[got]; dup {
			t.Errorf("styles %s and %s share filename prefix %q", name, prev, got)
		}
		seen[got] = name
		if strings.Contains(got, "illustrious-") || strings.Contains(got, "pony-") {
			t.Errorf("%s: alias not shortened: %q", name, got)
		}
	}
}
