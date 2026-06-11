// Package prompt expands a language-neutral VisualBrief into backend-specific
// image prompts (dual prompting). FLUX and Pony want very different prompt
// shapes, so rather than hand-writing two prompts per concept we author one
// brief and template it into both.
//
//   - FLUX: a natural sentence plus a style suffix. Distilled FLUX effectively
//     ignores the negative prompt, so everything (including what to avoid) is
//     folded into the positive prompt.
//   - Pony: score tags + danbooru-style tags + a full negative prompt.
//
// Adding another backend/style is just another Style entry over the same brief.
package prompt

import (
	"fmt"
	"strings"

	"github.com/duolingocards/quiz-generator/internal/content"
)

// Backend identifies the prompt dialect a style targets.
type Backend string

const (
	BackendFlux Backend = "flux"
	BackendPony Backend = "pony"
)

// Style is a named image configuration: which backend dialect to emit and the
// positive suffix / extra negatives that give the style its look.
type Style struct {
	Name           string  // e.g. "flux-real", "pony-cartoon"
	Backend        Backend // prompt dialect
	PositiveSuffix string  // appended to the positive prompt (look & feel)
	ExtraNegative  string  // appended to the negative prompt (Pony only)
}

// Prompt is the expanded result for one (brief, style) pair.
type Prompt struct {
	Style    string
	Backend  Backend
	Positive string
	Negative string // empty for FLUX
}

// Built-in styles. The default pipeline ships one FLUX style; Pony is included
// to exercise the dual-prompting path and so a second visual can be added
// later without touching the briefs.
var (
	StyleFluxReal = Style{
		Name:           "flux-real",
		Backend:        BackendFlux,
		PositiveSuffix: "natural lighting, soft focus background, high detail, friendly children's book illustration style",
	}
	StylePonyCartoon = Style{
		Name:           "pony-cartoon",
		Backend:        BackendPony,
		PositiveSuffix: "(semi-realistic:1.2), (detailed cartoon:1.1), highly detailed, intricate details, soft realistic shading, volumetric lighting, natural colors, natural pose, wildlife photography style, detailed environment, solo",
	}
)

// DefaultStyles maps style name → Style for the built-ins.
var DefaultStyles = map[string]Style{
	StyleFluxReal.Name:    StyleFluxReal,
	StylePonyCartoon.Name: StylePonyCartoon,
}

// ponyQualityTags is the conventional Pony quality preamble.
const ponyQualityTags = "score_9, score_8_up, score_7_up, best quality, masterpiece, absurdres"

// ponyBaseNegative is the always-on Pony negative prompt.
const ponyBaseNegative = "text, watermark, signature, blurry, lowres, bad anatomy, extra limbs, deformed, abstract, stylized, minimalistic, deformed proportions, wrong anatomy, barbie doll, toy-like, plastic, low detail, sketch, mlp style, pony ears, cutie mark, chibi, huge eyes, oversized head, simplified shading, flat shading, source_pony, pony style, equine features, cartoonish, anime style"

// Expand renders a brief for a given style.
func Expand(b content.VisualBrief, s Style) Prompt {
	switch s.Backend {
	case BackendPony:
		return expandPony(b, s)
	default:
		return expandFlux(b, s)
	}
}

// ExpandByName looks the style up among the built-ins and expands it.
func ExpandByName(b content.VisualBrief, styleName string) (Prompt, error) {
	s, ok := DefaultStyles[styleName]
	if !ok {
		return Prompt{}, fmt.Errorf("unknown style %q", styleName)
	}
	return Expand(b, s), nil
}

func expandFlux(b content.VisualBrief, s Style) Prompt {
	// Natural sentence: "A friendly, sitting lion in savanna grass."
	var sb strings.Builder
	sb.WriteString("A ")
	if len(b.Attrs) > 0 {
		sb.WriteString(strings.Join(b.Attrs, ", "))
		sb.WriteString(" ")
	}
	sb.WriteString(b.Subject)
	if len(b.Setting) > 0 {
		sb.WriteString(" in ")
		sb.WriteString(strings.Join(b.Setting, ", "))
	}
	sb.WriteString(".")
	// Distilled FLUX ignores negatives → fold "avoid" into the positive prompt.
	if len(b.Avoid) > 0 {
		sb.WriteString(" Clean composition without ")
		sb.WriteString(strings.Join(b.Avoid, ", "))
		sb.WriteString(".")
	}
	if s.PositiveSuffix != "" {
		sb.WriteString(" ")
		sb.WriteString(s.PositiveSuffix)
	}
	return Prompt{Style: s.Name, Backend: BackendFlux, Positive: sb.String()}
}

func expandPony(b content.VisualBrief, s Style) Prompt {
	// Tag soup: score tags, subject, attrs, setting, style suffix.
	tags := []string{ponyQualityTags}
	if b.Subject != "" {
		tags = append(tags, b.Subject)
	}
	tags = append(tags, b.Attrs...)
	tags = append(tags, b.Setting...)
	if s.PositiveSuffix != "" {
		tags = append(tags, s.PositiveSuffix)
	}
	pos := strings.Join(tags, ", ")

	negParts := []string{ponyBaseNegative}
	if len(b.Avoid) > 0 {
		negParts = append(negParts, strings.Join(b.Avoid, ", "))
	}
	if s.ExtraNegative != "" {
		negParts = append(negParts, s.ExtraNegative)
	}
	return Prompt{
		Style:    s.Name,
		Backend:  BackendPony,
		Positive: pos,
		Negative: strings.Join(negParts, ", "),
	}
}
