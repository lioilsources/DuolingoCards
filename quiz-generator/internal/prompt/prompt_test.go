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
	p := Expand(lionBrief, StylePhoto)
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
// illustriousStyleNames is every shipped Illustrious preset. Keep it in step
// with CardStyle.all in lib/models/card_style.dart, which names them for users.
var illustriousStyleNames = []string{
	"illustrious-anime", "illustrious-storybook", "illustrious-flat", "illustrious-ukiyoe",
	"ink", "watercolor", "illustrious-oil", "pastel",
	"illustrious-mucha", "illustrious-vangogh",
}

func TestIllustriousStylesAreControlNetRestyles(t *testing.T) {
	for _, name := range illustriousStyleNames {
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

// Every preset must be visually distinct, or the store is offering the same
// picture under ten names. Identical style suffixes are the way that regresses.
func TestIllustriousStylesAreDistinct(t *testing.T) {
	seen := map[string]string{}
	for _, name := range illustriousStyleNames {
		s := DefaultStyles[name]
		if s.PositiveSuffix == "" {
			t.Errorf("%s: no PositiveSuffix, nothing gives it a look", name)
			continue
		}
		if prev, dup := seen[s.PositiveSuffix]; dup {
			t.Errorf("%s and %s share a PositiveSuffix", name, prev)
		}
		seen[s.PositiveSuffix] = name
	}
}

// ControlNet must release before sampling ends. Held to the last step it also
// dictates the surface, which is what made the first four presets look alike.
func TestIllustriousControlReleasesBeforeEnd(t *testing.T) {
	for _, name := range illustriousStyleNames {
		s := DefaultStyles[name]
		if s.ControlEnd >= 1.0 {
			t.Errorf("%s: ControlEnd=%v never releases", name, s.ControlEnd)
		}
		if s.Denoise > 1.0 {
			t.Errorf("%s: Denoise=%v exceeds 1", name, s.Denoise)
		}
	}
}

func TestExpandByNameUnknown(t *testing.T) {
	if _, err := ExpandByName(lionBrief, "does-not-exist"); err == nil {
		t.Fatal("expected error for unknown style")
	}
}
