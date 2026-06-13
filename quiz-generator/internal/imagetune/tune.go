package imagetune

import (
	"context"
	"crypto/rand"
	"fmt"
	"io"
	"math/big"

	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/prompt"
)

// imageValidator scores a generated image against the target. Implemented by
// *Validator; an interface so tests can inject fakes.
type imageValidator interface {
	Validate(ctx context.Context, img []byte, t Target) (Verdict, error)
}

// promptBuilder rewrites a prompt from validator feedback. Implemented by
// *Builder.
type promptBuilder interface {
	Refine(ctx context.Context, cur prompt.Prompt, t Target, v Verdict) (prompt.Prompt, Exchange, error)
}

// Options tunes the loop.
type Options struct {
	MaxIters       int     // iteration cap (default 4)
	ScoreThreshold float64 // accept when validator score >= this (default 8)
	AspectRatio    string  // default "1:1"
	Resolution     string  // default "1k"
	Log            io.Writer
}

// IterRecord captures one generate→validate→refine round for the transcript.
type IterRecord struct {
	N       int
	Prompt  prompt.Prompt
	Seed    int64
	Verdict Verdict
	Refine  *Exchange // builder exchange producing the next prompt; nil if accepted/last
}

// Result is the outcome of tuning one card.
type Result struct {
	Image      []byte // final (accepted or last) image bytes
	Prompt     prompt.Prompt
	Seed       int64
	Score      float64
	Passed     bool  // score crossed the threshold
	Iters      int
	Transcript []IterRecord
	// ValidatorErr is set when the validator never produced a usable verdict
	// (e.g. the model returned unparseable output). The generated image is still
	// returned and saved; the loop just cannot improve it.
	ValidatorErr error
}

// Tune runs the iterative loop for a single card and returns the final image,
// the prompt that produced it, and the full LLM transcript. It always keeps the
// last generated result (the accepted one on success, or the last attempt when
// the iteration cap is reached).
func Tune(ctx context.Context, gen imagegen.ImageGenerator, val imageValidator, bld promptBuilder, init prompt.Prompt, t Target, opts Options) (Result, error) {
	maxIters := opts.MaxIters
	if maxIters <= 0 {
		maxIters = 4
	}
	threshold := opts.ScoreThreshold
	if threshold <= 0 {
		threshold = 8
	}
	aspect := opts.AspectRatio
	if aspect == "" {
		aspect = "1:1"
	}
	res := opts.Resolution
	if res == "" {
		res = "1k"
	}

	var out Result
	cur := init
	for i := 1; i <= maxIters; i++ {
		seed := randSeed()
		resp, err := gen.Generate(ctx, imagegen.GenerateRequest{
			Prompt:         cur.Positive,
			NegativePrompt: cur.Negative,
			N:              1,
			AspectRatio:    aspect,
			Resolution:     res,
			ResponseFormat: "b64_json",
			Seed:           seed,
		})
		if err != nil {
			return out, fmt.Errorf("generate (iter %d): %w", i, err)
		}
		if len(resp.Data) == 0 {
			return out, fmt.Errorf("generate (iter %d): no image returned", i)
		}
		img, err := resp.Data[0].Bytes()
		if err != nil {
			return out, fmt.Errorf("decode image (iter %d): %w", i, err)
		}

		verdict, verr := val.Validate(ctx, img, t)
		rec := IterRecord{N: i, Prompt: cur, Seed: seed, Verdict: verdict}

		// The current attempt is always the latest result we'd keep.
		out.Image = img
		out.Prompt = cur
		out.Seed = seed
		out.Score = verdict.Score
		out.Passed = verdict.Score >= threshold
		out.Iters = i

		if verr != nil {
			// The validator gave no usable verdict (e.g. unparseable model
			// output). Keep the image we generated and record the raw response
			// for inspection, but stop — we have no signal to refine on.
			out.ValidatorErr = verr
			out.Transcript = append(out.Transcript, rec)
			logf(opts.Log, "  [tune] iter %d: validator error: %v\n         raw: %q\n", i, verr, truncate(verdict.RawResponse, 240))
			break
		}

		logIter(opts.Log, rec, threshold)

		if out.Passed || i == maxIters {
			out.Transcript = append(out.Transcript, rec)
			break
		}

		next, ex, rerr := bld.Refine(ctx, cur, t, verdict)
		rec.Refine = &ex
		out.Transcript = append(out.Transcript, rec)
		if rerr != nil {
			// Can't improve the prompt; stop with the last image we have.
			logf(opts.Log, "  [tune] refine failed, keeping last image: %v\n", rerr)
			break
		}
		logRefine(opts.Log, cur, next)
		cur = next
	}
	return out, nil
}

func randSeed() int64 {
	max := new(big.Int).Lsh(big.NewInt(1), 63)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return 1
	}
	return n.Int64()
}
