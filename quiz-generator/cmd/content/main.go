// Command content is the build-time tooling for the no-backend DuolingoCards
// pipeline. It operates on the deck-per-folder authoring format:
//
//	content lint    [-decks DIR] [-strict] [-images]   validate decks (DB-constraint replacement)
//	content build   [-decks DIR] [-out DIR] [-strict]  merge deck.yaml + i18n/*.yaml → deck.json
//	content prompts [-decks DIR] [-style NAME]          expand visual briefs → FLUX/Pony prompts
//	content images  [-decks DIR] [-deck SLUG] [-style NAME] [-url URL] [-workers N] [-force]
//
// All commands run entirely offline on local files in Git, except `images`
// which calls a ComfyUI server.
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"github.com/duolingocards/quiz-generator/internal/comfyuiimage"
	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/langs"
	"github.com/duolingocards/quiz-generator/internal/llm"
	"github.com/duolingocards/quiz-generator/internal/prompt"
	"github.com/duolingocards/quiz-generator/internal/translate"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	cmd := os.Args[1]
	args := os.Args[2:]

	var err error
	switch cmd {
	case "lint":
		err = runLint(args)
	case "build":
		err = runBuild(args)
	case "prompts":
		err = runPrompts(args)
	case "images":
		err = runImages(args)
	case "translate":
		err = runTranslate(args)
	case "-h", "--help", "help":
		usage()
		return
	default:
		fmt.Fprintf(os.Stderr, "unknown command %q\n\n", cmd)
		usage()
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprint(os.Stderr, `content — no-backend deck pipeline tooling

Usage:
  content lint    [-decks DIR] [-strict] [-images]
  content build   [-decks DIR] [-out DIR] [-strict]
  content prompts [-decks DIR] [-deck SLUG] [-style NAME]
  content images     [-decks DIR] [-deck SLUG] [-style NAME] [-url URL] [-workers N] [-force]
  content translate  [-decks DIR] [-deck SLUG] [-lang CODE] [-url URL] [-workers N] [-force]

Commands:
  lint     Validate decks: card spine, translation coverage, orphan keys, schema.
  build    Merge deck.yaml + i18n/*.yaml into runtime deck.json files.
  prompts  Expand language-neutral visual briefs into FLUX + Pony prompts.
  images   Generate card images via ComfyUI (FLUX) and save to decks/<slug>/images/<style>/.

Common flags:
  -decks DIR   Root folder containing deck-per-folder subfolders (default "decks").
  -strict      Treat missing target-language translations as errors.
`)
}

// loadDecks loads every deck folder under root.
func loadDecks(root string) ([]*content.Deck, error) {
	dirs, err := content.FindDecks(root)
	if err != nil {
		return nil, fmt.Errorf("scanning %s: %w", root, err)
	}
	if len(dirs) == 0 {
		return nil, fmt.Errorf("no deck folders (with deck.yaml) found under %s", root)
	}
	var decks []*content.Deck
	for _, dir := range dirs {
		d, err := content.Load(dir)
		if err != nil {
			return nil, err
		}
		decks = append(decks, d)
	}
	return decks, nil
}

func runLint(args []string) error {
	fs := newFlagSet("lint")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	strict := fs.Bool("strict", false, "treat missing target-language translations as errors")
	images := fs.Bool("images", false, "verify each card image exists under images/<defaultStyle>/")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	opts := content.LintOptions{RequireAllTargets: *strict, CheckImages: *images}
	var allIssues []content.Issue
	for _, d := range decks {
		allIssues = append(allIssues, d.Lint(opts)...)
	}

	warns, errs := 0, 0
	for _, is := range allIssues {
		fmt.Println(is.String())
		if is.Severity == content.Error {
			errs++
		} else {
			warns++
		}
	}
	fmt.Printf("\nlinted %d deck(s): %d error(s), %d warning(s)\n", len(decks), errs, warns)
	if errs > 0 {
		return fmt.Errorf("lint failed with %d error(s)", errs)
	}
	return nil
}

func runBuild(args []string) error {
	fs := newFlagSet("build")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	outDir := fs.String("out", "output/decks", "output folder for deck.json files")
	strict := fs.Bool("strict", false, "fail the build if any deck has lint errors")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	opts := content.LintOptions{RequireAllTargets: *strict}
	built := 0
	for _, d := range decks {
		issues := d.Lint(opts)
		if content.HasErrors(issues) {
			for _, is := range issues {
				if is.Severity == content.Error {
					fmt.Fprintln(os.Stderr, is.String())
				}
			}
			return fmt.Errorf("deck %q has lint errors; not building", d.Meta.Slug)
		}
		path, err := d.Build().SaveJSON(*outDir)
		if err != nil {
			return err
		}
		fmt.Printf("built %s → %s (%d cards, %d languages)\n", d.Meta.Slug, path, len(d.Meta.Cards), len(d.Langs))
		built++
	}
	fmt.Printf("\nbuilt %d deck(s) into %s\n", built, *outDir)
	return nil
}

func runPrompts(args []string) error {
	fs := newFlagSet("prompts")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	deckSlug := fs.String("deck", "", "only expand this deck slug (default: all)")
	styleName := fs.String("style", "", "style to expand (default: each deck's default_style)")
	asJSON := fs.Bool("json", false, "emit prompts as JSON instead of text")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	type promptOut struct {
		Deck string `json:"deck"`
		Card string `json:"card"`
		prompt.Prompt
	}
	var out []promptOut

	for _, d := range decks {
		if *deckSlug != "" && d.Meta.Slug != *deckSlug {
			continue
		}
		style := *styleName
		if style == "" {
			style = d.Meta.DefaultStyle
		}
		if style == "" {
			return fmt.Errorf("deck %q has no default_style; pass -style", d.Meta.Slug)
		}
		for _, c := range d.Meta.Cards {
			p, err := prompt.ExpandByName(c.Brief, style)
			if err != nil {
				return err
			}
			out = append(out, promptOut{Deck: d.Meta.Slug, Card: c.Key, Prompt: p})
		}
	}

	if *asJSON {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		return enc.Encode(out)
	}
	for _, p := range out {
		fmt.Printf("# %s / %s  [%s · %s]\n", p.Deck, p.Card, p.Style, p.Backend)
		fmt.Printf("positive: %s\n", p.Positive)
		if p.Negative != "" {
			fmt.Printf("negative: %s\n", p.Negative)
		}
		fmt.Println()
	}
	return nil
}

func runImages(args []string) error {
	fs := newFlagSet("images")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	deckSlug := fs.String("deck", "", "only generate images for this deck slug (default: all)")
	styleName := fs.String("style", "", "style to generate (default: each deck's default_style)")
	comfyURL := fs.String("url", "http://spark-99bb:8188", "ComfyUI server base URL")
	workers := fs.Int("workers", 2, "parallel image generation workers")
	force := fs.Bool("force", false, "regenerate images that already exist")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	client := comfyuiimage.NewClient(*comfyURL, "", "")

	type job struct {
		deck     *content.Deck
		card     content.CardYAML
		style    string
		outPath  string
		positive string
		negative string
	}

	var jobs []job
	for _, d := range decks {
		if *deckSlug != "" && d.Meta.Slug != *deckSlug {
			continue
		}
		style := *styleName
		if style == "" {
			style = d.Meta.DefaultStyle
		}
		if style == "" {
			return fmt.Errorf("deck %q has no default_style; pass -style", d.Meta.Slug)
		}
		outDir := filepath.Join(d.Dir, "images", style)
		if err := os.MkdirAll(outDir, 0755); err != nil {
			return fmt.Errorf("create output dir: %w", err)
		}
		for _, c := range d.Meta.Cards {
			if c.Image == "" || c.Brief.Subject == "" {
				continue
			}
			outPath := filepath.Join(outDir, c.Image)
			if !*force {
				if info, err := os.Stat(outPath); err == nil && info.Size() > 0 {
					fmt.Printf("  SKIP %s/%s (exists)\n", d.Meta.Slug, c.Key)
					continue
				}
			}
			p, err := prompt.ExpandByName(c.Brief, style)
			if err != nil {
				return fmt.Errorf("expand prompt for %s/%s: %w", d.Meta.Slug, c.Key, err)
			}
			jobs = append(jobs, job{deck: d, card: c, style: style, outPath: outPath, positive: p.Positive, negative: p.Negative})
		}
	}

	if len(jobs) == 0 {
		fmt.Println("nothing to generate")
		return nil
	}
	fmt.Printf("generating %d image(s) via %s with %d worker(s)\n\n", len(jobs), *comfyURL, *workers)

	work := make(chan job, len(jobs))
	for _, j := range jobs {
		work <- j
	}
	close(work)

	var mu sync.Mutex
	generated, failed := 0, 0

	var wg sync.WaitGroup
	for i := 0; i < *workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := range work {
				label := fmt.Sprintf("%s/%s", j.deck.Meta.Slug, j.card.Key)
				resp, err := client.Generate(context.Background(), imagegen.GenerateRequest{
					Prompt:         j.positive,
					NegativePrompt: j.negative,
					N:              1,
					AspectRatio:    "1:1",
					Resolution:     "1k",
					ResponseFormat: "b64_json",
				})
				mu.Lock()
				if err != nil {
					failed++
					fmt.Printf("  FAIL %s: %v\n", label, err)
					mu.Unlock()
					continue
				}
				imgBytes, err := resp.Data[0].Bytes()
				if err != nil {
					failed++
					fmt.Printf("  FAIL %s: decode: %v\n", label, err)
					mu.Unlock()
					continue
				}
				if err := os.WriteFile(j.outPath, imgBytes, 0644); err != nil {
					failed++
					fmt.Printf("  FAIL %s: write: %v\n", label, err)
					mu.Unlock()
					continue
				}
				generated++
				fmt.Printf("  OK   %s → %s\n", label, j.outPath)
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	fmt.Printf("\ngenerated %d, failed %d\n", generated, failed)
	if failed > 0 {
		return fmt.Errorf("%d image(s) failed", failed)
	}
	return nil
}

func runTranslate(args []string) error {
	fs := newFlagSet("translate")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	deckSlug := fs.String("deck", "", "only translate this deck slug (default: all)")
	langCode := fs.String("lang", "", "only translate this language code (default: all missing)")
	llmURL := fs.String("url", "http://spark-99bb:4000", "LLM base URL (OpenAI-compatible)")
	llmModel := fs.String("model", "llm-lab", "model name")
	workers := fs.Int("workers", 3, "parallel translation workers (one per language)")
	force := fs.Bool("force", false, "re-translate even if i18n file already exists")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	client := llm.NewClient(*llmURL, *llmModel)

	// Determine target languages.
	targets := langs.Targets
	if *langCode != "" {
		found := false
		for _, t := range langs.Targets {
			if t.Code == *langCode {
				targets = []langs.Target{t}
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("unknown language code %q", *langCode)
		}
	}

	type job struct {
		deck   *content.Deck
		target langs.Target
	}
	var jobs []job
	for _, d := range decks {
		if *deckSlug != "" && d.Meta.Slug != *deckSlug {
			continue
		}
		if d.PivotLang() == "" {
			fmt.Fprintf(os.Stderr, "  SKIP %s: no pivot language\n", d.Meta.Slug)
			continue
		}
		for _, t := range targets {
			jobs = append(jobs, job{deck: d, target: t})
		}
	}

	if len(jobs) == 0 {
		fmt.Println("nothing to translate")
		return nil
	}
	fmt.Printf("translating %d language(s) via %s model=%s workers=%d\n\n", len(jobs), *llmURL, *llmModel, *workers)

	work := make(chan job, len(jobs))
	for _, j := range jobs {
		work <- j
	}
	close(work)

	var mu sync.Mutex
	done, failed := 0, 0

	var wg sync.WaitGroup
	for i := 0; i < *workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := range work {
				label := fmt.Sprintf("%s → %s (%s)", j.deck.Meta.Slug, j.target.Code, j.target.Name)
				path, err := translate.Translate(context.Background(), client, j.deck, j.target, *force)
				mu.Lock()
				if err != nil {
					failed++
					fmt.Printf("  FAIL %s: %v\n", label, err)
				} else {
					done++
					fmt.Printf("  OK   %s → %s\n", label, path)
				}
				mu.Unlock()
			}
		}()
	}
	wg.Wait()

	fmt.Printf("\ntranslated %d, failed %d\n", done, failed)
	if failed > 0 {
		return fmt.Errorf("%d translation(s) failed", failed)
	}
	return nil
}
