package imagetune

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/duolingocards/quiz-generator/internal/llm"
	"github.com/duolingocards/quiz-generator/internal/prompt"
)

// textClient is the subset of llm.Client the builder needs.
type textClient interface {
	Complete(ctx context.Context, system, user string) (string, error)
	Model() string
}

// Builder rewrites an image prompt from validator feedback, keeping it in the
// backend's dialect (Pony tag-soup vs FLUX sentence), using an instruct model.
type Builder struct {
	c textClient
}

// NewBuilder wraps an instruct LLM client.
func NewBuilder(c *llm.Client) *Builder { return &Builder{c: c} }

// Exchange is one request/response pair with a model, captured for the transcript.
type Exchange struct {
	Model    string
	Request  string
	Response string
}

const builderSystem = `You are an expert prompt engineer for text-to-image models.
You are given the concept an image must depict, the current image prompt, and a
QA reviewer's critique of the last generated image. Rewrite the prompt so the
NEXT generation fixes the reviewer's issues while still depicting the concept.

Rules:
- Keep the prompt in the required dialect (described below). Do not switch styles.
- Keep the same subject and intent; change wording, emphasis, attributes and the
  negative prompt to address the critique. Strengthen what the reviewer said was
  wrong or missing; suppress what should be avoided.
- Output ONLY a JSON object, no prose:
  {"positive": "...", "negative": "..."}
  For dialects that ignore negatives, return an empty "negative".

Dialect: %s`

// Refine produces an improved prompt. It returns the new prompt plus the raw
// exchange for logging.
func (b *Builder) Refine(ctx context.Context, cur prompt.Prompt, t Target, v Verdict) (prompt.Prompt, Exchange, error) {
	system := fmt.Sprintf(builderSystem, prompt.DialectGuide(cur.Backend))

	var user strings.Builder
	user.WriteString("Concept the image must depict:\n")
	user.WriteString(t.Describe())
	user.WriteString("\nCurrent positive prompt:\n")
	user.WriteString(cur.Positive)
	if cur.Negative != "" {
		user.WriteString("\n\nCurrent negative prompt:\n")
		user.WriteString(cur.Negative)
	}
	user.WriteString("\n\nReviewer score: ")
	user.WriteString(fmt.Sprintf("%.1f/10\n", v.Score))
	if len(v.Issues) > 0 {
		user.WriteString("Reviewer issues:\n- ")
		user.WriteString(strings.Join(v.Issues, "\n- "))
		user.WriteString("\n")
	}
	if v.Suggestions != "" {
		user.WriteString("Reviewer suggestions: ")
		user.WriteString(string(v.Suggestions))
		user.WriteString("\n")
	}

	ex := Exchange{Model: b.c.Model(), Request: user.String()}
	raw, err := b.c.Complete(ctx, system, user.String())
	if err != nil {
		return prompt.Prompt{}, ex, fmt.Errorf("builder call: %w", err)
	}
	ex.Response = raw

	jsonStr, err := extractJSON(raw)
	if err != nil {
		return prompt.Prompt{}, ex, fmt.Errorf("builder returned no JSON: %w", err)
	}
	var parsed struct {
		Positive string `json:"positive"`
		Negative string `json:"negative"`
	}
	if err := json.Unmarshal([]byte(jsonStr), &parsed); err != nil {
		return prompt.Prompt{}, ex, fmt.Errorf("parse builder JSON: %w", err)
	}
	if strings.TrimSpace(parsed.Positive) == "" {
		return prompt.Prompt{}, ex, fmt.Errorf("builder returned empty positive prompt")
	}
	next := prompt.Prompt{
		Style:    cur.Style,
		Backend:  cur.Backend,
		Positive: parsed.Positive,
		Negative: parsed.Negative,
	}
	return next, ex, nil
}
