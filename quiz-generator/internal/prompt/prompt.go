// Package prompt expands a language-neutral VisualBrief into backend-specific
// image prompts (dual prompting). FLUX and Pony want very different prompt
// shapes, so rather than hand-writing two prompts per concept we author one
// brief and template it into both.
//
//   - FLUX: a natural sentence plus a style suffix. Distilled FLUX effectively
//     ignores the negative prompt, so everything (including what to avoid) is
//     folded into the positive prompt.
//   - Pony: score tags + danbooru-style tags + a full negative prompt.
//   - Illustrious: danbooru-style tags like Pony, but a different quality
//     preamble (no score_* tags, which Pony invented and Illustrious never saw)
//     and negatives that suppress the anime characters it defaults to.
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
	BackendFlux        Backend = "flux"
	BackendPony        Backend = "pony"
	BackendIllustrious Backend = "illustrious"
)

// Style is a named image configuration: which backend dialect to emit and the
// positive suffix / extra negatives that give the style its look.
type Style struct {
	Name           string  // e.g. "photo", "pony-cartoon"
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
	// pass (e.g. "photo"). Only meaningful when Img2Img is true.
	BaseStyle string
	// Denoise is the KSampler denoise (0..1) for the img2img pass. Lower keeps more
	// of the base structure; higher repaints more freely. Only used when Img2Img.
	Denoise float64

	// ControlNet marks a *structure-locked* restyle: on top of the img2img pass the
	// base image is also run through an edge detector and fed to ControlNet, which
	// pins the subject's silhouette and anatomy independently of the latent. That
	// lifts the denoise ceiling — plain img2img dissolves the subject much above
	// ~0.65, while a ControlNet-locked pass survives 0.8+ and so lets the style
	// model commit. This is what makes Illustrious usable for concepts it cannot
	// draw on its own (an ant's six legs come from the FLUX base, the look comes
	// from Illustrious). Only meaningful when Img2Img is true.
	ControlNet bool
	// ControlStrength is the ControlNet strength (0 → keep the workflow default).
	// Raise it when the repaint drifts off the base anatomy.
	ControlStrength float64
	// ControlEnd is ControlNetApplyAdvanced's end_percent: the fraction of sampling
	// steps ControlNet stays applied. Releasing it before the end lets the style
	// model finish the surface (brushwork, shading) unconstrained. 0 → default.
	ControlEnd float64
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
	StylePhoto = Style{
		Name:           "photo",
		Backend:        BackendFlux,
		PositiveSuffix: "natural lighting, soft focus background, high detail, friendly children's book illustration style",
	}
	StylePonyCartoon = Style{
		Name:           "pony-cartoon",
		Backend:        BackendPony,
		PositiveSuffix: "(semi-realistic:1.2), (detailed cartoon:1.1), highly detailed, intricate details, soft realistic shading, volumetric lighting, natural colors, natural pose, wildlife photography style, detailed environment, solo",
	}

	// StylePonyWatercolor and StylePonyOil are img2img restyle presets: they take
	// each card's photo base image and repaint it through Pony SDXL in a paint
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
		BaseStyle: "photo",
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
		BaseStyle: "photo",
		Denoise:   0.65,
	}

	// The Illustrious styles are ControlNet-locked restyles (see Style.ControlNet).
	// Illustrious knows a far wider range of art styles than Pony, but a much
	// narrower range of real-world objects — it cannot draw an ant. Pairing it with
	// a FLUX base solves both halves: FLUX supplies the subject, ControlNet pins
	// that subject's shape through the repaint, and Illustrious supplies the look
	// at a denoise that plain img2img could not survive.
	//
	// The shared negative already suppresses anime characters (see
	// illustriousBaseNegative); each style's ExtraNegative only has to push away
	// from the photoreal look of the FLUX base.
	StyleIllustriousAnime = Style{
		Name:    "illustrious-anime",
		Backend: BackendIllustrious,
		PositiveSuffix: "(anime style:1.3), (anime screencap:1.2), crisp clean lineart, " +
			"cel shading, vibrant saturated colors, bold color blocking, simple clean background",
		ExtraNegative: "(photorealistic:1.3), (photograph:1.2), 3d render, hdr, realistic texture, " +
			"muted colors, soft focus, depth of field",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.80,
		ControlNet:      true,
		ControlStrength: 0.85,
		ControlEnd:      0.80,
	}
	StyleIllustriousStorybook = Style{
		Name:    "illustrious-storybook",
		Backend: BackendIllustrious,
		PositiveSuffix: "(children's picture book illustration:1.4), (storybook art:1.2), " +
			"soft watercolor washes, gentle hand-drawn linework, warm pastel palette, " +
			"cozy friendly mood, textured paper",
		ExtraNegative: "(photorealistic:1.3), (photograph:1.2), 3d render, hdr, realistic texture, " +
			"harsh contrast, dark gritty, sharp digital edges",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.75,
		ControlNet:      true,
		ControlStrength: 0.90,
		ControlEnd:      0.85,
	}
	StyleIllustriousFlat = Style{
		Name:    "illustrious-flat",
		Backend: BackendIllustrious,
		PositiveSuffix: "(flat vector illustration:1.4), (sticker art:1.2), bold clean outlines, " +
			"flat color fills, minimal shading, limited palette, plain background, " +
			"high readability at small size",
		ExtraNegative: "(photorealistic:1.3), (photograph:1.2), 3d render, hdr, realistic texture, " +
			"gradient, soft shading, detailed background, volumetric lighting, noise, grain",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.85,
		ControlNet:      true,
		ControlStrength: 0.95,
		ControlEnd:      0.90,
	}
	StyleIllustriousUkiyoe = Style{
		Name:    "illustrious-ukiyoe",
		Backend: BackendIllustrious,
		PositiveSuffix: "(ukiyo-e:1.4), (japanese woodblock print:1.3), bold black contour lines, " +
			"flat color areas, mineral pigments, subtle ink gradation, visible washi paper texture",
		ExtraNegative: "(photorealistic:1.3), (photograph:1.2), 3d render, hdr, realistic texture, " +
			"volumetric lighting, smooth digital gradient, western oil painting",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.85,
		ControlNet:      true,
		ControlStrength: 0.90,
		ControlEnd:      0.85,
	}

	// The medium and artist presets below push much harder than the four above,
	// which sat close to the FLUX base because ControlNet stayed applied for
	// 80-90% of sampling — the style model never got unconstrained steps to lay
	// down its own surface. These hold the structure only through the early
	// composition steps (ControlEnd 0.45-0.60) and then let go, at a denoise
	// high enough (0.86-0.92) for the medium to actually assert itself. The
	// silhouette still comes from the base; the paint no longer does.

	// Not sumi-e, despite the name: this preset cannot go monochrome, because the
	// card's own brief names the subject's colours ("orange and black patterned
	// wings", "red apple") and no negative outweighs an explicit positive. Raising
	// denoise to 0.97 was tried and made it worse — the latent is nearly pure noise
	// there, the colour still arrived from the prompt, and "rice paper" started
	// being drawn as literal bowls of rice. So the preset is what it reliably is:
	// brush-and-ink graphics that keep the subject's colour, sliding into near
	// monochrome on its own whenever the subject has a limited palette.
	StyleInk = Style{
		Name:    "ink",
		Backend: BackendIllustrious,
		PositiveSuffix: "(ink brush painting:1.5), (sumi-e brushwork:1.3), " +
			"(black ink outlines:1.2), expressive loose brushstrokes, wet ink bleeding into fibres, " +
			"dry brush texture, large areas of empty washi paper, minimal restrained composition, " +
			"single accent of vermilion seal",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"digital vector, flat solid fill, smooth gradient, " +
			"busy background, hard mechanical outlines, (rice:1.2), bowl of rice, food",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.90,
		ControlNet:      true,
		ControlStrength: 0.70,
		ControlEnd:      0.50,
	}
	StyleWatercolor = Style{
		Name:    "watercolor",
		Backend: BackendIllustrious,
		PositiveSuffix: "(watercolor painting:1.5), (wet-on-wet washes:1.3), " +
			"luminous translucent pigment, blooming color bleeds, granulating pigment settling, " +
			"soft feathered edges, white paper showing through, cold-press paper grain, " +
			"loose botanical illustration",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"opaque paint, hard crisp outlines, digital vector, flat solid fill, cel shading, " +
			"heavy black lineart, plastic shading",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.88,
		ControlNet:      true,
		ControlStrength: 0.72,
		ControlEnd:      0.55,
	}
	StyleIllustriousOil = Style{
		Name:    "illustrious-oil",
		Backend: BackendIllustrious,
		PositiveSuffix: "(oil painting:1.5), (thick impasto:1.3), (visible palette knife strokes:1.2), " +
			"loaded brush, rich buttery pigment, glazed layers, deep chiaroscuro, " +
			"warm earthy palette, coarse canvas weave, classical still life",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"thin transparent washes, watercolor, digital vector, flat solid fill, cel shading, " +
			"clean lineart, smooth digital gradient",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.88,
		ControlNet:      true,
		ControlStrength: 0.75,
		ControlEnd:      0.55,
	}
	StylePastel = Style{
		Name:    "pastel",
		Backend: BackendIllustrious,
		PositiveSuffix: "(soft pastel drawing:1.5), (chalk pastel on toned paper:1.3), " +
			"velvety powdery pigment, visible chalk strokes, smudged blended edges, " +
			"tooth of the paper breaking the color, muted dusty palette, " +
			"warm grey paper showing through",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"glossy, wet paint, hard crisp outlines, digital vector, flat solid fill, " +
			"cel shading, high contrast, neon colors",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.88,
		ControlNet:      true,
		ControlStrength: 0.72,
		ControlEnd:      0.52,
	}
	// Artist presets. Naming a movement plus its signature marks works better on
	// Illustrious than the artist's name alone, which mostly moves the palette.
	StyleIllustriousMucha = Style{
		Name:    "illustrious-mucha",
		Backend: BackendIllustrious,
		PositiveSuffix: "(art nouveau:1.5), (alphonse mucha style:1.4), " +
			"ornamental decorative panel, sinuous whiplash linework, flowing organic arabesques, " +
			"gold leaf accents, muted mauve and sage and cream palette, " +
			"circular halo motif behind the subject, stylized floral border, flat decorative background",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"harsh contrast, neon colors, chaotic composition, modern digital art, cel shading",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.90,
		ControlNet:      true,
		ControlStrength: 0.68,
		ControlEnd:      0.48,
	}
	StyleIllustriousVanGogh = Style{
		Name:    "illustrious-vangogh",
		Backend: BackendIllustrious,
		PositiveSuffix: "(post-impressionism:1.5), (van gogh style:1.4), " +
			"(swirling thick impasto brushstrokes:1.3), short rhythmic directional strokes, " +
			"turbulent swirling background, vivid complementary colors, cobalt blue and chrome yellow, " +
			"heavy paint ridges catching light, expressive distorted energy",
		ExtraNegative: "(photorealistic:1.4), (photograph:1.3), 3d render, hdr, realistic texture, " +
			"smooth blending, flat solid fill, digital vector, cel shading, clean lineart, " +
			"muted desaturated colors",
		Img2Img:         true,
		BaseStyle:       "photo",
		Denoise:         0.92,
		ControlNet:      true,
		ControlStrength: 0.65,
		ControlEnd:      0.45,
	}
)

// DefaultStyles maps style name → Style for the built-ins.
var DefaultStyles = map[string]Style{
	StylePhoto.Name:              StylePhoto,
	StylePonyCartoon.Name:           StylePonyCartoon,
	StylePonyWatercolor.Name:        StylePonyWatercolor,
	StylePonyOil.Name:               StylePonyOil,
	StyleIllustriousAnime.Name:      StyleIllustriousAnime,
	StyleIllustriousStorybook.Name:  StyleIllustriousStorybook,
	StyleIllustriousFlat.Name:       StyleIllustriousFlat,
	StyleIllustriousUkiyoe.Name:     StyleIllustriousUkiyoe,
	StyleInk.Name:        StyleInk,
	StyleWatercolor.Name: StyleWatercolor,
	StyleIllustriousOil.Name:        StyleIllustriousOil,
	StylePastel.Name:     StylePastel,
	StyleIllustriousMucha.Name:      StyleIllustriousMucha,
	StyleIllustriousVanGogh.Name:    StyleIllustriousVanGogh,
}

// ponyQualityTags is the conventional Pony quality preamble.
const ponyQualityTags = "score_9, score_8_up, score_7_up, best quality, masterpiece, absurdres"

// ponyBaseNegative is the always-on Pony negative prompt.
const ponyBaseNegative = "text, watermark, signature, blurry, lowres, bad anatomy, extra limbs, deformed, abstract, stylized, minimalistic, deformed proportions, wrong anatomy, barbie doll, toy-like, plastic, low detail, sketch, mlp style, pony ears, cutie mark, chibi, huge eyes, oversized head, simplified shading, flat shading, source_pony, pony style, equine features, cartoonish, anime style"

// illustriousQualityTags is the conventional Illustrious quality preamble. Note
// the absence of score_*: those are a Pony-specific training convention that
// Illustrious never saw, and including them only wastes conditioning.
const illustriousQualityTags = "masterpiece, best quality, amazing quality, very aesthetic, absurdres"

// illustriousBaseNegative is the always-on Illustrious negative prompt. Beyond
// the usual quality tags it leans hard on suppressing people: Illustrious is
// trained overwhelmingly on anime characters and will otherwise smuggle a girl,
// a face or a pair of hands into a card that should show only the concept.
const illustriousBaseNegative = "bad quality, worst quality, worst detail, lowres, jpeg artifacts, sketch, censor, " +
	"text, watermark, signature, logo, speech bubble, " +
	"1girl, 1boy, solo, human, person, character, face, eyes, hands, humanoid, anthropomorphic, " +
	"bad anatomy, extra limbs, missing limbs, deformed, mutated, ugly, cropped, out of frame"

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
	case BackendIllustrious:
		return "Illustrious/SDXL dialect: a comma-separated tag soup, NOT prose. " +
			"Always keep the quality preamble \"" + illustriousQualityTags + "\" at the front. " +
			"Never use Pony score_* tags — Illustrious was not trained on them. " +
			"Use danbooru-style tags for the subject, pose, and setting; weight emphasis with (tag:1.2). " +
			"Provide a full negative prompt of unwanted tags; the always-on base negatives are: \"" + illustriousBaseNegative + "\"."
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
		return expandTags(b, s, ponyQualityTags, ponyBaseNegative)
	case BackendIllustrious:
		return expandTags(b, s, illustriousQualityTags, illustriousBaseNegative)
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

// expandTags renders a brief in the danbooru tag-soup dialect shared by the
// SDXL-family backends. The only per-backend difference is the quality preamble
// and the always-on negative, so both are passed in.
func expandTags(b content.VisualBrief, s Style, qualityTags, baseNegative string) Prompt {
	// Tag soup: quality preamble, subject, attrs, setting, style suffix.
	tags := []string{qualityTags}
	if b.Subject != "" {
		tags = append(tags, b.Subject)
	}
	tags = append(tags, b.Attrs...)
	tags = append(tags, b.Setting...)
	if s.PositiveSuffix != "" {
		tags = append(tags, s.PositiveSuffix)
	}
	pos := strings.Join(tags, ", ")

	negParts := []string{baseNegative}
	if len(b.Avoid) > 0 {
		negParts = append(negParts, strings.Join(b.Avoid, ", "))
	}
	if s.ExtraNegative != "" {
		negParts = append(negParts, s.ExtraNegative)
	}
	return Prompt{
		Style:    s.Name,
		Backend:  s.Backend,
		Positive: pos,
		Negative: strings.Join(negParts, ", "),
	}
}
