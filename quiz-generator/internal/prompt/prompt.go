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

	// Img2Img marks a restyle preset: instead of text-to-image, the card's base
	// image (generated in BaseStyle) is repainted through the Pony SDXL model via
	// ComfyUI img2img (LoadImage → VAEEncode → KSampler at Denoise<1), so the base
	// composition is preserved while the medium changes. Inspired by Kiran's
	// flux2pony restyle pass.
	Img2Img bool
	// BaseStyle is the style whose images/<BaseStyle>/ outputs feed the img2img
	// pass (e.g. "flux-real"). Only meaningful when Img2Img is true.
	BaseStyle string
	// Denoise is the KSampler denoise (0..1) for the img2img pass. Lower keeps more
	// of the base structure; higher repaints more freely. Only used when Img2Img.
	Denoise float64
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

	// StylePonyWatercolor and StylePonyOil are img2img restyle presets: they take
	// each card's flux-real base image and repaint it through Pony SDXL in a paint
	// medium (see Style.Img2Img). Goal: keep the subject/composition of the base
	// but push the medium hard. The medium tags are attention-weighted (SDXL
	// (tag:1.4) syntax) so the limited repaint commits to the style, the extra
	// negatives push away from the photoreal/flat look of the flux base, and
	// denoise stays moderate so the subject is preserved (raising denoise would
	// also drift the subject). Tune the balance live with -denoise / DENOISE=.
	StylePonyWatercolor = Style{
		Name:    "pony-watercolor",
		Backend: BackendPony,
		PositiveSuffix: "(watercolor painting:1.4), (traditional watercolor illustration:1.3), " +
			"(soft wet-on-wet washes:1.2), luminous translucent pigments, soft feathered edges, " +
			"visible cold-press paper grain, hand-painted brushwork, gentle color bleeds, (painterly:1.2)",
		ExtraNegative: "hard edges, sharp crisp outlines, 3d render, (photorealistic:1.3), (photograph:1.2), " +
			"sharp focus, hdr, realistic texture, digital vector, flat solid fill, smooth digital gradient, " +
			"harsh lines, plastic shading",
		Img2Img:   true,
		BaseStyle: "flux-real",
		Denoise:   0.62,
	}
	StylePonyOil = Style{
		Name:    "pony-oil",
		Backend: BackendPony,
		PositiveSuffix: "(oil painting:1.4), (thick impasto brushstrokes:1.3), (visible palette knife texture:1.2), " +
			"rich saturated pigments, glossy layered paint, chiaroscuro lighting, (painterly:1.2), " +
			"classical fine art, textured canvas weave",
		ExtraNegative: "thin washes, watercolor, flat solid fill, digital vector, 3d render, (photorealistic:1.3), " +
			"(photograph:1.2), sharp focus, hdr, realistic texture, smooth digital gradient, plastic shading, clean lineart",
		Img2Img:   true,
		BaseStyle: "flux-real",
		Denoise:   0.65,
	}
)

// DefaultStyles maps style name → Style for the built-ins.
var DefaultStyles = map[string]Style{
	StyleFluxReal.Name:       StyleFluxReal,
	StylePonyCartoon.Name:    StylePonyCartoon,
	StylePonyWatercolor.Name: StylePonyWatercolor,
	StylePonyOil.Name:        StylePonyOil,
}

// ponyQualityTags is the conventional Pony quality preamble.
const ponyQualityTags = "score_9, score_8_up, score_7_up, best quality, masterpiece, absurdres"

// ponyBaseNegative is the always-on Pony negative prompt.
const ponyBaseNegative = "text, watermark, signature, blurry, lowres, bad anatomy, extra limbs, deformed, abstract, stylized, minimalistic, deformed proportions, wrong anatomy, barbie doll, toy-like, plastic, low detail, sketch, mlp style, pony ears, cutie mark, chibi, huge eyes, oversized head, simplified shading, flat shading, source_pony, pony style, equine features, cartoonish, anime style"

// DialectGuide returns a short description of the prompt conventions a backend
// expects. It is meant to be embedded in an LLM system prompt so a prompt-tuning
// model rewrites prompts in the same dialect Expand would have produced.
func DialectGuide(b Backend) string {
	switch b {
	case BackendPony:
		return "Pony/SDXL dialect: a comma-separated tag soup, NOT prose. " +
			"Always keep the quality preamble \"" + ponyQualityTags + "\" at the front. " +
			"Use danbooru-style tags for the subject, pose, and setting; weight emphasis with (tag:1.2). " +
			"Provide a full negative prompt of unwanted tags; the always-on base negatives are: \"" + ponyBaseNegative + "\"."
	default:
		return "FLUX dialect: one natural-language sentence describing the subject, " +
			"its attributes and setting (e.g. \"A calm sitting lion in savanna grass, golden hour.\"). " +
			"Distilled FLUX ignores negative prompts, so fold anything to avoid into the positive " +
			"sentence (\"...clean composition without text, blood.\"). Leave the negative prompt empty."
	}
}

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

// settingPrepositions are words a setting phrase may already start with, so
// expandFlux does not produce a double preposition like "in on a flower".
var settingPrepositions = map[string]bool{
	"on": true, "in": true, "at": true, "near": true, "under": true, "by": true,
	"over": true, "above": true, "below": true, "inside": true, "atop": true,
	"amid": true, "among": true, "against": true, "beside": true,
}

func startsWithPreposition(s string) bool {
	first := s
	if i := strings.IndexByte(s, ' '); i >= 0 {
		first = s[:i]
	}
	return settingPrepositions[strings.ToLower(first)]
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
		setting := strings.Join(b.Setting, ", ")
		// Some settings already begin with a preposition (e.g. "on a flower");
		// only prepend "in" for bare noun-phrase settings ("savanna grass") so we
		// never emit a double preposition like "in on a flower".
		if startsWithPreposition(setting) {
			sb.WriteString(", ")
		} else {
			sb.WriteString(" in ")
		}
		sb.WriteString(setting)
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
