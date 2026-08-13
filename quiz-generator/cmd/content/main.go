// Command content is the build-time tooling for the no-backend DuolingoCards
// pipeline. It operates on the deck-per-folder authoring format:
//
//	content lint    [-decks DIR] [-strict] [-images]   validate decks (DB-constraint replacement)
//	content build   [-decks DIR] [-out DIR] [-strict]  merge deck.yaml + i18n/*.yaml → deck.json
//	content prompts [-decks DIR] [-style NAME]          expand visual briefs → FLUX/Pony/Illustrious prompts
//	content images  [-decks DIR] [-deck SLUG] [-style NAME] [-url URL] [-workers N] [-force]
//	                [-tune [-max-iters N] [-score-threshold F] [-llm-url URL]
//	                       [-validator-model M] [-builder-model M] [-tune-log-json]]
//	                [-pony-checkpoint NAME] [-illustrious-checkpoint NAME] [-controlnet NAME]
//	                [-denoise F] [-control-strength F]
//
// All commands run entirely offline on local files in Git, except `images`
// which calls a ComfyUI server (and, with -tune, an OpenAI-compatible LLM server
// for the validate→refine loop).
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/duolingocards/quiz-generator/internal/comfyuiimage"
	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/imagetune"
	"github.com/duolingocards/quiz-generator/internal/langs"
	"github.com/duolingocards/quiz-generator/internal/llm"
	"github.com/duolingocards/quiz-generator/internal/prompt"
	"github.com/duolingocards/quiz-generator/internal/translate"
)

// mergedBrief returns a copy of the card brief with deck-level BriefAttrs
// prepended — but only for the text-to-image pass that produces the base.
//
// brief_attrs is scaffolding for that base: "macro photography",
// "(photorealistic texture:1.1)", "soft studio lighting", "clean white
// background". A restyle pass does not need it (the subject arrives via the
// base image and ControlNet) and is actively harmed by it — food-fruits asks
// for "(vibrant colors:1.3)" while illustrious-ink asks for "(monochrome:1.2)",
// and the two cancel. Carrying photoreal scaffolding into every repaint is a
// large part of why restyles drift back toward the look of the base.
func mergedBrief(c content.CardYAML, d *content.Deck, style prompt.Style) content.VisualBrief {
	b := c.Brief
	if style.Img2Img || len(d.Meta.BriefAttrs) == 0 {
		return b
	}
	merged := make([]string, 0, len(d.Meta.BriefAttrs)+len(b.Attrs))
	merged = append(merged, d.Meta.BriefAttrs...)
	merged = append(merged, b.Attrs...)
	b.Attrs = merged
	return b
}

// briefFor resolves the style by name and merges the brief accordingly.
func briefFor(c content.CardYAML, d *content.Deck, styleName string) (content.VisualBrief, prompt.Style, error) {
	s, ok := prompt.DefaultStyles[styleName]
	if !ok {
		return content.VisualBrief{}, prompt.Style{}, fmt.Errorf("unknown style %q", styleName)
	}
	return mergedBrief(c, d, s), s, nil
}

// buildTarget assembles the tuning Target for a card: the concept the image must
// depict. It uses the card's own brief (not the deck-level brief_attrs, which are
// model scaffolding, not part of the concept) plus the disambiguation hint and,
// when available, the pivot-language label for extra grounding.
func buildTarget(c content.CardYAML, d *content.Deck) imagetune.Target {
	t := imagetune.Target{
		Subject: c.Brief.Subject,
		Hint:    c.Hint,
		Attrs:   c.Brief.Attrs,
		Setting: c.Brief.Setting,
		Avoid:   c.Brief.Avoid,
	}
	if pl := d.PivotLang(); pl != "" {
		if f, ok := d.I18n[pl]; ok {
			if ci, ok := f.Cards[c.Key]; ok {
				t.Label = ci.Label
			}
		}
	}
	return t
}

// imageFilenamePrefix builds the ComfyUI filename_prefix for a card image so the
// output appears in the UI as e.g. "cards-animals-pets-dog-flux" instead of the
// generic "cards_*" default.
func imageFilenamePrefix(deckSlug, cardKey, style string) string {
	// Strip namespace prefix from card key: "pets.dog" → "dog"
	keyPart := cardKey
	if i := strings.LastIndex(cardKey, "."); i >= 0 {
		keyPart = cardKey[i+1:]
	}
	// Short style alias: "flux-real" → "flux", "pony-cartoon" → "pony"
	styleAlias := style
	switch style {
	case "flux-real":
		styleAlias = "flux"
	case "pony-cartoon":
		styleAlias = "pony"
	case "pony-watercolor":
		styleAlias = "watercolor"
	case "pony-oil":
		styleAlias = "oil"
	case "illustrious-anime":
		styleAlias = "anime"
	case "illustrious-storybook":
		styleAlias = "storybook"
	case "illustrious-flat":
		styleAlias = "flat"
	case "illustrious-ukiyoe":
		styleAlias = "ukiyoe"
	case "illustrious-ink":
		styleAlias = "ink"
	case "illustrious-watercolor":
		styleAlias = "watercolor-illu"
	case "illustrious-oil":
		styleAlias = "oil-illu"
	case "illustrious-pastel":
		styleAlias = "pastel"
	case "illustrious-mucha":
		styleAlias = "mucha"
	case "illustrious-vangogh":
		styleAlias = "vangogh"
	}
	return fmt.Sprintf("cards-%s-%s-%s", deckSlug, keyPart, styleAlias)
}

// writeTranscript saves the per-card tuning transcript (Markdown, and optionally
// JSON) under decks/<slug>/tuned/logs/.
func writeTranscript(deckDir, card, style string, t imagetune.Target, result imagetune.Result, alsoJSON bool) error {
	logDir := filepath.Join(deckDir, "tuned", "logs")
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return err
	}
	f, err := os.Create(filepath.Join(logDir, card+"."+style+".md"))
	if err != nil {
		return err
	}
	imagetune.RenderTranscript(f, card, style, t, result)
	if err := f.Close(); err != nil {
		return err
	}
	if alsoJSON {
		data, err := imagetune.TranscriptJSON(card, style, t, result)
		if err != nil {
			return err
		}
		if err := os.WriteFile(filepath.Join(logDir, card+"."+style+".json"), data, 0644); err != nil {
			return err
		}
	}
	return nil
}

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
	case "styles":
		err = runStyles(args)
	case "publish":
		err = runPublish(args)
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
  content styles

Commands:
  lint     Validate decks: card spine, translation coverage, orphan keys, schema.
  build    Merge deck.yaml + i18n/*.yaml into runtime deck.json files.
  prompts  Expand language-neutral visual briefs into FLUX + Pony prompts.
  images   Generate card images via ComfyUI (FLUX) and save to decks/<slug>/images/<style>/.

Common flags:
  -decks DIR   Root folder containing deck-per-folder subfolders (default "decks").
  -strict      Treat missing target-language translations as errors.

Restyle styles (images):
  pony-watercolor, pony-oil          img2img repaint of the flux-real base through Pony SDXL.
  illustrious-anime, -storybook,     img2img repaint through Illustrious with a ControlNet
  -flat, -ukiyoe                     structure lock, so a high denoise keeps the base anatomy.
  Tune with -denoise / -control-strength; pick models with
  -pony-checkpoint / -illustrious-checkpoint / -controlnet.
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
	appRoot := fs.String("app-root", ".", "Flutter repo root (pubspec.yaml, assets/previews, docs/decks) used to record per-style delivery")
	webp := fs.Bool("webp", false, "emit .webp image names in deck.json (match this to publish -webp-quality)")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	app := content.AppLayout{Root: *appRoot}.WebPImages(*webp)
	if !app.Valid() {
		fmt.Fprintf(os.Stderr,
			"warning: no pubspec.yaml under -app-root %q; deck.json will omit styleAvailability and the store will offer every style\n",
			*appRoot)
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
		rd := d.BuildFor(app)
		path, err := rd.SaveJSON(*outDir)
		if err != nil {
			return err
		}
		fmt.Printf("built %s → %s (%d cards, %d supported languages, styles: %s)\n",
			d.Meta.Slug, path, len(d.Meta.Cards), len(rd.Titles), describeStyles(rd))
		built++
	}
	fmt.Printf("\nbuilt %d deck(s) into %s\n", built, *outDir)
	return nil
}

// runPublish copies complete styles into the app's preview tree and the CDN
// tree, which is what makes them offerable in the store.
func runPublish(args []string) error {
	fs := newFlagSet("publish")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	deckSlug := fs.String("deck", "", "only publish this deck slug (default: all)")
	style := fs.String("style", "", "only publish this style (default: every complete style)")
	previews := fs.String("previews", "assets/previews", "app-bundled preview root (empty to skip)")
	cdn := fs.String("cdn", "docs/decks", "published CDN tree root (empty to skip)")
	built := fs.String("built", "assets/decks", "folder holding built deck.json files")
	previewCards := fs.Int("preview-cards", 3, "how many leading cards go into the preview set")
	what := fs.String("what", "all", "what to publish: images, json, or all")
	webpQuality := fs.Int("webp-quality", 0, "re-encode published images to WebP at this quality (0 = copy PNG unchanged; 85 is the shipping default)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *what != "images" && *what != "json" && *what != "all" {
		return fmt.Errorf("-what must be images, json or all (got %q)", *what)
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	opts := content.PublishOptions{
		PreviewsDir:  *previews,
		CDNDir:       *cdn,
		BuiltDir:     *built,
		PreviewCards: *previewCards,
		Style:        *style,
		Images:       *what == "images" || *what == "all",
		WebPQuality:  *webpQuality,
		JSON:         *what == "json" || *what == "all",
	}

	published := 0
	for _, d := range decks {
		if *deckSlug != "" && d.Meta.Slug != *deckSlug {
			continue
		}
		res, err := d.Publish(opts)
		if err != nil {
			return fmt.Errorf("deck %s: %w", d.Meta.Slug, err)
		}
		for _, s := range d.ImageStyles() {
			if opts.Style != "" && opts.Style != s {
				continue
			}
			fmt.Printf("%s / %-24s previews %2d  cdn %3d\n", d.Meta.Slug, s, res.Previews[s], res.CDN[s])
		}
		if res.JSON {
			fmt.Printf("%s / deck.json → %s\n", d.Meta.Slug, filepath.Join(*cdn, d.Meta.Slug, "deck.json"))
		}
		published++
	}
	fmt.Printf("\npublished %d deck(s)\n", published)
	return nil
}

// runStyles lists every registered style with the knobs that decide how far a
// restyle drifts from its base, so picking one does not mean reading the source.
func runStyles(args []string) error {
	fs := newFlagSet("styles")
	if err := fs.Parse(args); err != nil {
		return err
	}

	names := make([]string, 0, len(prompt.DefaultStyles))
	for name := range prompt.DefaultStyles {
		names = append(names, name)
	}
	sort.Strings(names)

	fmt.Printf("%-26s %-12s %-11s %-8s %-6s %s\n",
		"STYLE", "BACKEND", "PASS", "DENOISE", "CN", "CN-END")
	for _, name := range names {
		s := prompt.DefaultStyles[name]
		pass := "text2img"
		if s.Img2Img && s.ControlNet {
			pass = "cn-img2img"
		} else if s.Img2Img {
			pass = "img2img"
		}
		dash := func(f float64) string {
			if f == 0 {
				return "-"
			}
			return fmt.Sprintf("%.2f", f)
		}
		fmt.Printf("%-26s %-12s %-11s %-8s %-6s %s\n",
			name, s.Backend, pass, dash(s.Denoise), dash(s.ControlStrength), dash(s.ControlEnd))
	}
	return nil
}

// describeStyles renders the built style list with how each one reaches the
// app, so a style that is authored but undeliverable is visible in build output
// instead of only showing up as a missing chip in the store.
func describeStyles(rd *content.RuntimeDeck) string {
	if len(rd.Styles) == 0 {
		return "none"
	}
	parts := make([]string, 0, len(rd.Styles))
	for _, s := range rd.Styles {
		a, ok := rd.StyleAvailability[s]
		if !ok {
			parts = append(parts, s)
			continue
		}
		var how []string
		if a.Bundled {
			how = append(how, "bundled")
		}
		if a.CDN {
			how = append(how, "cdn")
		}
		if len(how) == 0 {
			how = append(how, "undelivered")
		}
		parts = append(parts, fmt.Sprintf("%s[%s]", s, strings.Join(how, "+")))
	}
	return strings.Join(parts, " ")
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
			b, _, err := briefFor(c, d, style)
			if err != nil {
				return err
			}
			p, err := prompt.ExpandByName(b, style)
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
	tune := fs.Bool("tune", false, "iterative tuning: generate → validate (VL model) → refine prompt (instruct model) → loop")
	maxIters := fs.Int("max-iters", 4, "tuning: max generate/validate iterations per card")
	scoreThreshold := fs.Float64("score-threshold", 8, "tuning: accept image when validator score >= this (0-10)")
	llmURL := fs.String("llm-url", "http://spark-99bb:8080", "tuning: OpenAI-compatible LLM base URL for validator + builder")
	validatorModel := fs.String("validator-model", "qwen-vl", "tuning: vision-language model that scores images")
	builderModel := fs.String("builder-model", "nemotron", "tuning: instruct model that rewrites prompts")
	tuneLogJSON := fs.Bool("tune-log-json", false, "tuning: also write a machine-readable JSON transcript per card")
	ponyCheckpoint := fs.String("pony-checkpoint", "ponyDiffusionV6XL_v6StartWithThisOne.safetensors", "Pony SDXL checkpoint for img2img restyle styles (pony-watercolor, pony-oil)")
	illustriousCheckpoint := fs.String("illustrious-checkpoint", "Illustrious-XL-v2.0.safetensors", "Illustrious checkpoint for ControlNet restyle styles (illustrious-*)")
	controlNetModel := fs.String("controlnet", "controlnet-union-sdxl-promax-xinsir.safetensors", "SDXL ControlNet model used by the illustrious-* restyle styles")
	denoiseOverride := fs.Float64("denoise", 0, "img2img restyle: override the style's KSampler denoise (0..1; 0 = style default). Higher repaints more freely; lower keeps more of the base.")
	controlStrengthOverride := fs.Float64("control-strength", 0, "ControlNet restyle: override the style's ControlNet strength (0 = style default). Higher keeps the base anatomy more strictly.")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}

	ponyClient := comfyuiimage.NewClient(*comfyURL, "", "")
	fluxClient := comfyuiimage.NewClient(*comfyURL, "", "", comfyuiimage.WithFluxDev())
	// restyleClients run the img2img restyle passes over a flux base image, one per
	// style backend: Pony repaints in a paint medium, Illustrious repaints in an art
	// style with a ControlNet holding the subject's shape.
	restyleClients := map[prompt.Backend]*comfyuiimage.Client{
		prompt.BackendPony: comfyuiimage.NewClient(*comfyURL, "", "",
			comfyuiimage.WithWorkflow(comfyuiimage.PonyImg2ImgWorkflow()),
			comfyuiimage.WithNodeRoles(comfyuiimage.Img2ImgNodeRoles()),
			comfyuiimage.WithCheckpoint(*ponyCheckpoint)),
		prompt.BackendIllustrious: comfyuiimage.NewClient(*comfyURL, "", "",
			comfyuiimage.WithWorkflow(comfyuiimage.IllustriousControlNetWorkflow()),
			comfyuiimage.WithNodeRoles(comfyuiimage.IllustriousControlNetNodeRoles()),
			comfyuiimage.WithCheckpoint(*illustriousCheckpoint),
			comfyuiimage.WithControlNet(*controlNetModel)),
	}

	var validator *imagetune.Validator
	var builder *imagetune.Builder
	if *tune {
		validator = imagetune.NewValidator(llm.NewClient(*llmURL, *validatorModel))
		builder = imagetune.NewBuilder(llm.NewClient(*llmURL, *builderModel))
	}

	type job struct {
		deck     *content.Deck
		card     content.CardYAML
		style    string
		backend  prompt.Backend
		outPath  string
		positive string
		negative string
		seed     int64 // from a tuned sidecar override; 0 = random
		// img2img restyle (e.g. pony-watercolor / illustrious-anime): repaint basePath.
		img2img  bool
		basePath string  // base image to restyle (images/<baseStyle>/<image>)
		denoise  float64 // KSampler denoise for the restyle pass
		// ControlNet structure lock (illustrious-* styles); 0 = graph default.
		controlStrength float64
		controlEnd      float64
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
		st := prompt.DefaultStyles[style] // zero value if unknown; ExpandByName below reports it
		if st.Img2Img && *tune {
			return fmt.Errorf("style %q is an img2img restyle; -tune is not supported for it", style)
		}
		outDir := filepath.Join(d.Dir, "images", style)
		if err := os.MkdirAll(outDir, 0755); err != nil {
			return fmt.Errorf("create output dir: %w", err)
		}
		// Tuned sidecar: the prompt that previously produced each card's image.
		// Used as a reproducible override (and as a warm start when re-tuning).
		tuned, err := content.LoadTuned(d.Dir, style)
		if err != nil {
			return fmt.Errorf("load tuned sidecar for %s: %w", d.Meta.Slug, err)
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
			b, _, err := briefFor(c, d, style)
			if err != nil {
				return err
			}
			p, err := prompt.ExpandByName(b, style)
			if err != nil {
				return fmt.Errorf("expand prompt for %s/%s: %w", d.Meta.Slug, c.Key, err)
			}
			j := job{deck: d, card: c, style: style, backend: p.Backend, outPath: outPath, positive: p.Positive, negative: p.Negative}
			if st.Img2Img {
				// Restyle needs the base-style image to already exist.
				basePath := filepath.Join(d.Dir, "images", st.BaseStyle, c.Image)
				if info, err := os.Stat(basePath); err != nil || info.Size() == 0 {
					fmt.Printf("  SKIP %s/%s (no %s base image at %s — generate it first)\n", d.Meta.Slug, c.Key, st.BaseStyle, basePath)
					continue
				}
				j.img2img = true
				j.basePath = basePath
				j.denoise = st.Denoise
				if *denoiseOverride > 0 {
					j.denoise = *denoiseOverride
				}
				if st.ControlNet {
					j.controlStrength = st.ControlStrength
					j.controlEnd = st.ControlEnd
					if *controlStrengthOverride > 0 {
						j.controlStrength = *controlStrengthOverride
					}
				}
			}
			if entry, ok := tuned[c.Key]; ok {
				j.positive = entry.Positive
				j.negative = entry.Negative
				j.seed = entry.Seed
			}
			jobs = append(jobs, j)
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

				// img2img restyle pass (pony-* / illustrious-*): repaint the base
				// image through an SDXL model instead of text-to-image.
				if j.img2img {
					restyleClient, ok := restyleClients[j.backend]
					if !ok {
						mu.Lock()
						failed++
						fmt.Printf("  FAIL %s: no restyle client for backend %q\n", label, j.backend)
						mu.Unlock()
						continue
					}
					baseBytes, rerr := os.ReadFile(j.basePath)
					if rerr != nil {
						mu.Lock()
						failed++
						fmt.Printf("  FAIL %s: read base: %v\n", label, rerr)
						mu.Unlock()
						continue
					}
					keyPart := j.card.Key
					if i := strings.LastIndex(keyPart, "."); i >= 0 {
						keyPart = keyPart[i+1:]
					}
					out, gerr := restyleClient.GenerateImg2Img(context.Background(), comfyuiimage.Img2ImgRequest{
						BaseImage:       baseBytes,
						BaseFilename:    fmt.Sprintf("restyle-%s-%s.png", j.deck.Meta.Slug, keyPart),
						Prompt:          j.positive,
						NegativePrompt:  j.negative,
						FilenamePrefix:  imageFilenamePrefix(j.deck.Meta.Slug, j.card.Key, j.style),
						Denoise:         j.denoise,
						Seed:            j.seed,
						ControlStrength: j.controlStrength,
						ControlEnd:      j.controlEnd,
					})
					mu.Lock()
					if gerr != nil {
						failed++
						fmt.Printf("  FAIL %s: %v\n", label, gerr)
					} else if werr := os.WriteFile(j.outPath, out, 0644); werr != nil {
						failed++
						fmt.Printf("  FAIL %s: write: %v\n", label, werr)
					} else {
						generated++
						if j.controlStrength > 0 {
							fmt.Printf("  OK   %s → %s (img2img, denoise %.2f, controlnet %.2f)\n", label, j.outPath, j.denoise, j.controlStrength)
						} else {
							fmt.Printf("  OK   %s → %s (img2img, denoise %.2f)\n", label, j.outPath, j.denoise)
						}
					}
					mu.Unlock()
					continue
				}

				imgClient := ponyClient
				if j.backend == prompt.BackendFlux {
					imgClient = fluxClient
				}

				if *tune {
					fmt.Printf("  TUNE %s\n", label)
					init := prompt.Prompt{Style: j.style, Backend: j.backend, Positive: j.positive, Negative: j.negative}
					target := buildTarget(j.card, j.deck)
					result, err := imagetune.Tune(context.Background(), imgClient, validator, builder, init, target, imagetune.Options{
						MaxIters:       *maxIters,
						ScoreThreshold: *scoreThreshold,
						AspectRatio:    "1:1",
						Resolution:     "1k",
						Log:            os.Stderr,
						FilenamePrefix: imageFilenamePrefix(j.deck.Meta.Slug, j.card.Key, j.style),
					})
					if err == nil {
						err = os.WriteFile(j.outPath, result.Image, 0644)
					}
					if err != nil {
						mu.Lock()
						failed++
						fmt.Printf("  FAIL %s: %v\n", label, err)
						mu.Unlock()
						continue
					}
					mu.Lock()
					serr := content.SaveTuned(j.deck.Dir, j.style, j.card.Key, content.TunedEntry{
						Positive:  result.Prompt.Positive,
						Negative:  result.Prompt.Negative,
						Seed:      result.Seed,
						Score:     result.Score,
						Model:     *builderModel,
						Iters:     result.Iters,
						UpdatedAt: time.Now().UTC().Format(time.RFC3339),
					})
					mu.Unlock()
					if serr != nil {
						fmt.Fprintf(os.Stderr, "  WARN %s: save tuned sidecar: %v\n", label, serr)
					}
					if terr := writeTranscript(j.deck.Dir, j.card.Key, j.style, target, result, *tuneLogJSON); terr != nil {
						fmt.Fprintf(os.Stderr, "  WARN %s: write transcript: %v\n", label, terr)
					}
					mu.Lock()
					generated++
					if result.ValidatorErr != nil {
						fmt.Printf("  WARN %s → %s saved, but validator gave no usable verdict: %v (see transcript)\n", label, j.outPath, result.ValidatorErr)
					} else {
						fmt.Printf("  OK   %s → %s (score %.1f, %d iter, seed %d)\n", label, j.outPath, result.Score, result.Iters, result.Seed)
					}
					mu.Unlock()
					continue
				}

				resp, err := imgClient.Generate(context.Background(), imagegen.GenerateRequest{
					Prompt:         j.positive,
					NegativePrompt: j.negative,
					N:              1,
					AspectRatio:    "1:1",
					Resolution:     "1k",
					ResponseFormat: "b64_json",
					Seed:           j.seed,
					FilenamePrefix: imageFilenamePrefix(j.deck.Meta.Slug, j.card.Key, j.style),
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
	llmURL := fs.String("url", "http://spark-99bb:8080", "LLM base URL (OpenAI-compatible)")
	llmModel := fs.String("model", "translate", "model name")
	workers := fs.Int("workers", 8, "parallel translation workers (one per language)")
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
				mu.Lock()
				fmt.Printf("  ...  %s\n", label)
				mu.Unlock()
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
