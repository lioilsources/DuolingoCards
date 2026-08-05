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

// Illustrious shares Pony's tag-soup shape but must not inherit its score_ tags,
// and its negative has to carry the character suppression that keeps anime people
// out of a card that should show only the concept.
func TestExpandIllustrious(t *testing.T) {
	p := Expand(lionBrief, StyleIllustriousAnime)
	if p.Backend != BackendIllustrious {
		t.Fatalf("backend = %s", p.Backend)
	}
	if !strings.HasPrefix(p.Positive, illustriousQualityTags) {
		t.Fatalf("Illustrious positive should start with the quality preamble: %q", p.Positive)
	}
	if strings.Contains(p.Positive, "score_") {
		t.Fatalf("Illustrious positive must not carry Pony score tags: %q", p.Positive)
	}
	for _, want := range []string{"lion", "sitting", "savanna grass", "anime style"} {
		if !strings.Contains(p.Positive, want) {
			t.Fatalf("Illustrious positive missing %q: %q", want, p.Positive)
		}
	}
	for _, want := range []string{"1girl", "human", "face", "worst quality", "text", "blood", "photorealistic"} {
		if !strings.Contains(p.Negative, want) {
			t.Fatalf("Illustrious negative missing %q: %q", want, p.Negative)
		}
	}
}

// Every illustrious-* style is a ControlNet-locked restyle over a flux base;
// none of them can generate from text, so the restyle fields must all be set.
func TestIllustriousStylesAreControlNetRestyles(t *testing.T) {
	names := []string{"illustrious-anime", "illustrious-storybook", "illustrious-flat", "illustrious-ukiyoe"}
	for _, name := range names {
		s, ok := DefaultStyles[name]
		if !ok {
			t.Fatalf("style %q not registered in DefaultStyles", name)
		}
		if s.Backend != BackendIllustrious {
			t.Errorf("%s: backend = %s, want %s", name, s.Backend, BackendIllustrious)
		}
		if !s.Img2Img || !s.ControlNet {
			t.Errorf("%s: Img2Img=%v ControlNet=%v, want both true", name, s.Img2Img, s.ControlNet)
		}
		if s.BaseStyle == "" {
			t.Errorf("%s: BaseStyle is empty", name)
		}
		if _, ok := DefaultStyles[s.BaseStyle]; !ok {
			t.Errorf("%s: BaseStyle %q is not a registered style", name, s.BaseStyle)
		}
		if s.Denoise <= 0 || s.ControlStrength <= 0 || s.ControlEnd <= 0 {
			t.Errorf("%s: denoise=%v strength=%v end=%v, all must be > 0",
				name, s.Denoise, s.ControlStrength, s.ControlEnd)
		}
	}
}

func TestExpandByNameUnknown(t *testing.T) {
	if _, err := ExpandByName(lionBrief, "does-not-exist"); err == nil {
		t.Fatal("expected error for unknown style")
	}
}
