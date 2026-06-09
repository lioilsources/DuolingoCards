// Command content is the build-time tooling for the no-backend DuolingoCards
// pipeline. It operates on the deck-per-folder authoring format:
//
//	content lint    [-decks DIR] [-strict] [-images]   validate decks (DB-constraint replacement)
//	content build   [-decks DIR] [-out DIR] [-strict]  merge deck.yaml + i18n/*.yaml → deck.json
//	content prompts [-decks DIR] [-style NAME]          expand visual briefs → FLUX/Pony prompts
//
// All commands run entirely offline on local files in Git.
package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/prompt"
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

Commands:
  lint     Validate decks: card spine, translation coverage, orphan keys, schema.
  build    Merge deck.yaml + i18n/*.yaml into runtime deck.json files.
  prompts  Expand language-neutral visual briefs into FLUX + Pony prompts.

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
