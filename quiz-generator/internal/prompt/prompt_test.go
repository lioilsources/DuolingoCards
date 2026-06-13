package prompt

import (
	"strings"
	"testing"

	"github.com/duolingocards/quiz-generator/internal/content"
)

var lionBrief = content.VisualBrief{
	Subject: "lion",
	Attrs:   []string{"sitting", "calm"},
	Setting: []string{"savanna grass"},
	Avoid:   []string{"text", "blood"},
}

// FLUX folds "avoid" into the positive prompt (distilled FLUX ignores negatives)
// and emits no negative prompt.
func TestExpandFlux(t *testing.T) {
	p := Expand(lionBrief, StyleFluxReal)
	if p.Backend != BackendFlux {
		t.Fatalf("backend = %s", p.Backend)
	}
	if p.Negative != "" {
		t.Fatalf("FLUX should have no negative prompt, got %q", p.Negative)
	}
	for _, want := range []string{"lion", "sitting, calm", "savanna grass", "without text, blood"} {
		if !strings.Contains(p.Positive, want) {
			t.Fatalf("FLUX positive missing %q: %q", want, p.Positive)
		}
	}
}

// Pony emits score tags, danbooru-style tags, and a full negative prompt that
// includes both the base negatives and the brief's avoid list.
func TestExpandPony(t *testing.T) {
	p := Expand(lionBrief, StylePonyCartoon)
	if p.Backend != BackendPony {
		t.Fatalf("backend = %s", p.Backend)
	}
	if !strings.HasPrefix(p.Positive, "score_9") {
		t.Fatalf("Pony positive should start with score tags: %q", p.Positive)
	}
	for _, want := range []string{"text", "blood", "bad anatomy"} {
		if !strings.Contains(p.Negative, want) {
			t.Fatalf("Pony negative missing %q: %q", want, p.Negative)
		}
	}
}

func TestExpandByNameUnknown(t *testing.T) {
	if _, err := ExpandByName(lionBrief, "does-not-exist"); err == nil {
		t.Fatal("expected error for unknown style")
	}
}
