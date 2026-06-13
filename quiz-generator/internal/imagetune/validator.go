package imagetune

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/duolingocards/quiz-generator/internal/llm"
)

// visionClient is the subset of llm.Client the validator needs. It lets tests
// inject a fake without a live server.
type visionClient interface {
	CompleteVision(ctx context.Context, system, user string, img []byte) (string, error)
	Model() string
}

// Validator scores how well a generated image depicts the target concept, using
// a vision-language model over the OpenAI-compatible chat API.
type Validator struct {
	c visionClient
}

// NewValidator wraps a vision-capable LLM client.
func NewValidator(c *llm.Client) *Validator { return &Validator{c: c} }

// Verdict is the validator's judgement of one image.
type Verdict struct {
	Score       float64  `json:"score"`       // 0-10, higher is better
	Pass        bool     `json:"pass"`        // model's own accept/reject
	Issues      []string `json:"issues"`      // concrete problems with the image
	Suggestions string   `json:"suggestions"` // how to improve the prompt
	Model       string   `json:"-"`           // validator model name
	RawRequest  string   `json:"-"`           // user message sent (for transcript)
	RawResponse string   `json:"-"`           // raw model reply (for transcript)
}

const validatorSystem = `You are a strict visual QA reviewer for a flashcard app.
You are shown one AI-generated image and a description of the concept it must
depict. Judge ONLY whether the image clearly and correctly shows that concept:
the right subject/species, recognizable and anatomically plausible, matching the
requested attributes and setting, and free of the listed things to avoid.

Respond with ONLY a JSON object, no prose, in exactly this shape:
{"score": <0-10 number>, "pass": <true|false>, "issues": ["..."], "suggestions": "concrete prompt changes to fix the issues"}

Scoring guide: 10 = perfect depiction; 8-9 = clearly correct, minor nits;
5-7 = recognizable but with notable problems; 0-4 = wrong subject, deformed, or
violates an avoid constraint. Set "pass" to true only for score >= 8.`

// Validate sends the image and target to the vision model and parses its verdict.
func (v *Validator) Validate(ctx context.Context, img []byte, t Target) (Verdict, error) {
	user := "Concept the image must depict:\n" + t.Describe() + "\nReview the attached image."
	raw, err := v.c.CompleteVision(ctx, validatorSystem, user, img)
	if err != nil {
		return Verdict{}, fmt.Errorf("validator call: %w", err)
	}
	jsonStr, err := extractJSON(raw)
	if err != nil {
		return Verdict{Model: v.c.Model(), RawRequest: user, RawResponse: raw},
			fmt.Errorf("validator returned no JSON: %w", err)
	}
	var verdict Verdict
	if err := json.Unmarshal([]byte(jsonStr), &verdict); err != nil {
		return Verdict{Model: v.c.Model(), RawRequest: user, RawResponse: raw},
			fmt.Errorf("parse validator JSON: %w", err)
	}
	verdict.Model = v.c.Model()
	verdict.RawRequest = user
	verdict.RawResponse = raw
	return verdict, nil
}
