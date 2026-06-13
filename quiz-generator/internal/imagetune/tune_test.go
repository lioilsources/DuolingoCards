package imagetune

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"
	"testing"

	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/prompt"
)

type fakeGen struct{ n int }

func (f *fakeGen) Generate(ctx context.Context, req imagegen.GenerateRequest) (*imagegen.GenerateResponse, error) {
	f.n++
	b := []byte(fmt.Sprintf("img-%d-seed-%d-%s", f.n, req.Seed, req.Prompt))
	return &imagegen.GenerateResponse{Data: []imagegen.ImageData{{B64JSON: base64.StdEncoding.EncodeToString(b)}}}, nil
}

type fakeVal struct {
	scores []float64
	i      int
	calls  int
}

func (v *fakeVal) Validate(ctx context.Context, img []byte, t Target) (Verdict, error) {
	s := v.scores[len(v.scores)-1]
	if v.i < len(v.scores) {
		s = v.scores[v.i]
	}
	v.i++
	v.calls++
	return Verdict{
		Score: s, Pass: s >= 8,
		Issues: []string{"too generic"}, Suggestions: "add species detail",
		Model: "val-model", RawRequest: "validator req", RawResponse: fmt.Sprintf(`{"score":%v}`, s),
	}, nil
}

type fakeBld struct{ calls int }

func (b *fakeBld) Refine(ctx context.Context, cur prompt.Prompt, t Target, v Verdict) (prompt.Prompt, Exchange, error) {
	b.calls++
	next := prompt.Prompt{Style: cur.Style, Backend: cur.Backend,
		Positive: fmt.Sprintf("%s +r%d", cur.Positive, b.calls), Negative: cur.Negative}
	return next, Exchange{Model: "bld-model", Request: "builder req", Response: "builder resp"}, nil
}

func initPrompt() prompt.Prompt {
	return prompt.Prompt{Style: "pony-cartoon", Backend: prompt.BackendPony, Positive: "base", Negative: "neg"}
}

func TestTuneAcceptsOnThreshold(t *testing.T) {
	gen := &fakeGen{}
	val := &fakeVal{scores: []float64{9}}
	bld := &fakeBld{}
	out, err := Tune(context.Background(), gen, val, bld, initPrompt(), Target{Subject: "monarch butterfly"},
		Options{MaxIters: 4, ScoreThreshold: 8})
	if err != nil {
		t.Fatal(err)
	}
	if gen.n != 1 {
		t.Fatalf("want 1 generation, got %d", gen.n)
	}
	if bld.calls != 0 {
		t.Fatalf("builder should not run on first accept, got %d calls", bld.calls)
	}
	if !out.Passed || out.Score != 9 || out.Iters != 1 {
		t.Fatalf("unexpected result: passed=%v score=%v iters=%d", out.Passed, out.Score, out.Iters)
	}
	if len(out.Transcript) != 1 {
		t.Fatalf("want 1 transcript record, got %d", len(out.Transcript))
	}
	if !strings.Contains(string(out.Image), "img-1-") {
		t.Fatalf("final image should be the first generation, got %q", out.Image)
	}
}

func TestTuneHitsMaxIters(t *testing.T) {
	gen := &fakeGen{}
	val := &fakeVal{scores: []float64{5, 5, 5}}
	bld := &fakeBld{}
	out, err := Tune(context.Background(), gen, val, bld, initPrompt(), Target{Subject: "bee"},
		Options{MaxIters: 3, ScoreThreshold: 8})
	if err != nil {
		t.Fatal(err)
	}
	if gen.n != 3 {
		t.Fatalf("want 3 generations, got %d", gen.n)
	}
	// Refine runs after iter 1 and 2, but not after the final (capped) iter 3.
	if bld.calls != 2 {
		t.Fatalf("want 2 builder calls, got %d", bld.calls)
	}
	if out.Passed {
		t.Fatalf("should not pass at score 5")
	}
	if out.Iters != 3 || len(out.Transcript) != 3 {
		t.Fatalf("iters=%d transcript=%d", out.Iters, len(out.Transcript))
	}
	// Final prompt should reflect both refinements (last generated, the loop's intent).
	if out.Prompt.Positive != "base +r1 +r2" {
		t.Fatalf("final prompt not the last refined one: %q", out.Prompt.Positive)
	}
	if !strings.Contains(string(out.Image), "img-3-") {
		t.Fatalf("final image should be the last generation, got %q", out.Image)
	}
}

func TestTuneTranscriptCapturesExchanges(t *testing.T) {
	gen := &fakeGen{}
	val := &fakeVal{scores: []float64{4, 9}}
	bld := &fakeBld{}
	out, err := Tune(context.Background(), gen, val, bld, initPrompt(), Target{Subject: "ant"},
		Options{MaxIters: 4, ScoreThreshold: 8})
	if err != nil {
		t.Fatal(err)
	}
	if len(out.Transcript) != 2 {
		t.Fatalf("want 2 records, got %d", len(out.Transcript))
	}
	first := out.Transcript[0]
	if first.Verdict.RawResponse == "" || first.Verdict.Model != "val-model" {
		t.Fatalf("validator exchange not captured: %+v", first.Verdict)
	}
	if first.Refine == nil || first.Refine.Model != "bld-model" || first.Refine.Response == "" {
		t.Fatalf("builder exchange not captured on iter 1: %+v", first.Refine)
	}
	// Final (accepted) iteration has no refine.
	if out.Transcript[1].Refine != nil {
		t.Fatalf("accepted iteration should have no refine exchange")
	}
}
