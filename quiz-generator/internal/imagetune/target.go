// Package imagetune drives the iterative image-tuning loop:
//
//	generate (ComfyUI) → validate (vision model) → refine prompt (instruct model) → repeat
//
// Each card is tuned independently and sequentially: a fresh image is generated,
// a vision-language model scores how well it depicts the target concept, and an
// instruct model rewrites the prompt from that feedback. The loop stops when the
// score crosses a threshold or a max-iteration cap is hit, and returns the final
// image, the prompt that produced it, and a full transcript of the LLM exchange.
package imagetune

import "strings"

// Target is the concept an image must depict, assembled from a card's visual
// brief plus disambiguation hints. It grounds both the validator (what to check
// for) and the builder (what to keep the prompt about).
type Target struct {
	Subject string   // main subject, e.g. "monarch butterfly"
	Hint    string   // disambiguation note, e.g. "the insect, not the swimming stroke"
	Attrs   []string // desired attributes / poses
	Setting []string // desired background
	Avoid   []string // things to keep out
	Label   string   // optional pivot-language label for extra grounding
}

// Describe renders the target as a compact human/LLM-readable brief.
func (t Target) Describe() string {
	var sb strings.Builder
	sb.WriteString("Subject: ")
	sb.WriteString(t.Subject)
	if t.Label != "" {
		sb.WriteString(" (")
		sb.WriteString(t.Label)
		sb.WriteString(")")
	}
	sb.WriteString("\n")
	if t.Hint != "" {
		sb.WriteString("Disambiguation: ")
		sb.WriteString(t.Hint)
		sb.WriteString("\n")
	}
	if len(t.Attrs) > 0 {
		sb.WriteString("Desired attributes: ")
		sb.WriteString(strings.Join(t.Attrs, ", "))
		sb.WriteString("\n")
	}
	if len(t.Setting) > 0 {
		sb.WriteString("Desired setting: ")
		sb.WriteString(strings.Join(t.Setting, ", "))
		sb.WriteString("\n")
	}
	if len(t.Avoid) > 0 {
		sb.WriteString("Must avoid: ")
		sb.WriteString(strings.Join(t.Avoid, ", "))
		sb.WriteString("\n")
	}
	return sb.String()
}
