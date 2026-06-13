package imagetune

import (
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"github.com/duolingocards/quiz-generator/internal/prompt"
)

// logf writes to w if non-nil.
func logf(w io.Writer, format string, args ...any) {
	if w == nil {
		return
	}
	fmt.Fprintf(w, format, args...)
}

// logIter streams a compact per-iteration line: what the validator said.
func logIter(w io.Writer, rec IterRecord, threshold float64) {
	if w == nil {
		return
	}
	verdict := "reject"
	if rec.Verdict.Score >= threshold {
		verdict = "ACCEPT"
	}
	fmt.Fprintf(w, "  [tune] iter %d: validator(%s) score=%.1f %s\n",
		rec.N, rec.Verdict.Model, rec.Verdict.Score, verdict)
	if len(rec.Verdict.Issues) > 0 {
		fmt.Fprintf(w, "         issues: %s\n", strings.Join(rec.Verdict.Issues, "; "))
	}
	if rec.Verdict.Suggestions != "" {
		fmt.Fprintf(w, "         suggestions: %s\n", rec.Verdict.Suggestions)
	}
}

// logRefine streams the prompt change the builder produced.
func logRefine(w io.Writer, old, next prompt.Prompt) {
	if w == nil {
		return
	}
	fmt.Fprintf(w, "         builder → new positive: %s\n", truncate(next.Positive, 200))
	if next.Negative != old.Negative && next.Negative != "" {
		fmt.Fprintf(w, "         builder → new negative: %s\n", truncate(next.Negative, 200))
	}
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}

// TranscriptJSON renders the full tuning run as machine-readable JSON, including
// the raw validator and builder exchanges (which are omitted from Verdict's own
// JSON tags).
func TranscriptJSON(card, style string, t Target, out Result) ([]byte, error) {
	type validatorJSON struct {
		Model       string   `json:"model"`
		Score       float64  `json:"score"`
		Pass        bool     `json:"pass"`
		Issues      []string `json:"issues"`
		Suggestions string   `json:"suggestions"`
		RawRequest  string   `json:"raw_request"`
		RawResponse string   `json:"raw_response"`
	}
	type builderJSON struct {
		Model    string `json:"model"`
		Request  string `json:"request"`
		Response string `json:"response"`
	}
	type iterJSON struct {
		N         int           `json:"n"`
		Seed      int64         `json:"seed"`
		Positive  string        `json:"positive"`
		Negative  string        `json:"negative,omitempty"`
		Validator validatorJSON `json:"validator"`
		Builder   *builderJSON  `json:"builder,omitempty"`
	}
	doc := struct {
		Card       string     `json:"card"`
		Style      string     `json:"style"`
		Target     string     `json:"target"`
		Iters      int        `json:"iters"`
		Score      float64    `json:"score"`
		Passed     bool       `json:"passed"`
		Seed       int64      `json:"seed"`
		Iterations []iterJSON `json:"iterations"`
	}{
		Card: card, Style: style, Target: t.Describe(),
		Iters: out.Iters, Score: out.Score, Passed: out.Passed, Seed: out.Seed,
	}
	for _, rec := range out.Transcript {
		ij := iterJSON{
			N: rec.N, Seed: rec.Seed,
			Positive: rec.Prompt.Positive, Negative: rec.Prompt.Negative,
			Validator: validatorJSON{
				Model: rec.Verdict.Model, Score: rec.Verdict.Score, Pass: rec.Verdict.Pass,
				Issues: rec.Verdict.Issues, Suggestions: rec.Verdict.Suggestions,
				RawRequest: rec.Verdict.RawRequest, RawResponse: rec.Verdict.RawResponse,
			},
		}
		if rec.Refine != nil {
			ij.Builder = &builderJSON{Model: rec.Refine.Model, Request: rec.Refine.Request, Response: rec.Refine.Response}
		}
		doc.Iterations = append(doc.Iterations, ij)
	}
	return json.MarshalIndent(doc, "", "  ")
}

// RenderTranscript writes a human-readable Markdown record of the full tuning
// run — every prompt sent to and reply from the validator and builder — so it is
// clear what the tuning was based on and how each verdict changed the prompt.
func RenderTranscript(w io.Writer, card, style string, t Target, out Result) {
	fmt.Fprintf(w, "# Tuning transcript — %s [%s]\n\n", card, style)
	fmt.Fprintf(w, "Result: %d iteration(s), final score %.1f, passed=%t, seed=%d\n\n",
		out.Iters, out.Score, out.Passed, out.Seed)
	if out.ValidatorErr != nil {
		fmt.Fprintf(w, "> ⚠️ validator produced no usable verdict: %v\n\n", out.ValidatorErr)
	}
	fmt.Fprintf(w, "## Target\n\n```\n%s```\n\n", t.Describe())

	for _, rec := range out.Transcript {
		fmt.Fprintf(w, "## Iteration %d (seed %d)\n\n", rec.N, rec.Seed)
		fmt.Fprintf(w, "### Prompt generated from\n\n")
		fmt.Fprintf(w, "**positive:** %s\n\n", rec.Prompt.Positive)
		if rec.Prompt.Negative != "" {
			fmt.Fprintf(w, "**negative:** %s\n\n", rec.Prompt.Negative)
		}

		fmt.Fprintf(w, "### Validator (%s)\n\n", rec.Verdict.Model)
		fmt.Fprintf(w, "score: **%.1f**, pass: %t\n\n", rec.Verdict.Score, rec.Verdict.Pass)
		if len(rec.Verdict.Issues) > 0 {
			fmt.Fprintf(w, "issues:\n")
			for _, is := range rec.Verdict.Issues {
				fmt.Fprintf(w, "- %s\n", is)
			}
			fmt.Fprintln(w)
		}
		if rec.Verdict.Suggestions != "" {
			fmt.Fprintf(w, "suggestions: %s\n\n", rec.Verdict.Suggestions)
		}
		fmt.Fprintf(w, "<details><summary>raw validator request</summary>\n\n```\n%s\n```\n</details>\n\n", rec.Verdict.RawRequest)
		fmt.Fprintf(w, "<details><summary>raw validator response</summary>\n\n```\n%s\n```\n</details>\n\n", rec.Verdict.RawResponse)

		if rec.Refine != nil {
			fmt.Fprintf(w, "### Builder (%s) → refined prompt\n\n", rec.Refine.Model)
			fmt.Fprintf(w, "<details><summary>raw builder request</summary>\n\n```\n%s\n```\n</details>\n\n", rec.Refine.Request)
			fmt.Fprintf(w, "<details><summary>raw builder response</summary>\n\n```\n%s\n```\n</details>\n\n", rec.Refine.Response)
		}
	}
}
