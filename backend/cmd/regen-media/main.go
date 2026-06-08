// regen-media regenerates card images for vocabulary decks using a ComfyUI backend.
//
// Usage:
//
//	COMFYUI_API_URL=http://localhost:8188 go run ./cmd/regen-media \
//	  -english assets/data/english-50-animals.json \
//	  -out-dirs assets/media/english-50-animals,assets/media/japanese-50-animals
//
// The command reads the English deck JSON (which has English frontText values like "Dog",
// "Cat", etc.) and uses those as Flux prompts. The same images are written to all
// output directories — useful because both english-50-animals and japanese-50-animals
// share the same image filenames (named after the Czech backText slug).
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/example/duolingocards-backend/internal/services/image"
	"github.com/example/duolingocards-backend/internal/storage"
	"github.com/joho/godotenv"
)

const (
	fluxPromptTemplate = "Simple clean digital illustration of a %s, white background, flat icon style, no text, colorful, educational flashcard image"
	ponyPromptTemplate = "score_9, score_8_up, score_7_up, masterpiece, best quality, %s, white background, simple background, full body, cute, vibrant colors, (no text:1.5), no humans, solo"
)

type card struct {
	ID       string `json:"id"`
	FrontText string `json:"frontText"`
	BackText  string `json:"backText"`
	Reading  string `json:"reading"`
	Media    *struct {
		Image string `json:"image,omitempty"`
	} `json:"media,omitempty"`
}

type deck struct {
	ID    string `json:"id"`
	Cards []card `json:"cards"`
}

func main() {
	godotenv.Load()

	englishDeckPath := flag.String("english", "../../assets/data/english-50-animals.json", "Path to English animals deck JSON (source of English words for prompts)")
	outDirsFlag := flag.String("out-dirs", "../../assets/media/english-50-animals,../../assets/media/japanese-50-animals", "Comma-separated output directories for generated images")
	comfyURL := flag.String("comfyui-url", "", "ComfyUI server URL (overrides COMFYUI_API_URL env var)")
	timeout := flag.Duration("timeout", 15*time.Minute, "Per-image job timeout")
	force := flag.Bool("force", false, "Overwrite existing image files")
	dryRun := flag.Bool("dry-run", false, "Print prompts without calling ComfyUI")
	checkpoint := flag.String("checkpoint", "", "Override checkpoint name in workflow (e.g. ponyDiffusionV6XL_v6StartWithThisOne.safetensors)")
	workflowType := flag.String("workflow", "sd", "Workflow type: flux, flux-dev, pony, sd")
	promptFlag := flag.String("prompt", "", "Custom prompt template with %%s placeholder (overrides per-workflow default)")
	flag.Parse()

	// Resolve ComfyUI URL
	url := *comfyURL
	if url == "" {
		url = os.Getenv("COMFYUI_API_URL")
	}
	if url == "" && !*dryRun {
		log.Fatal("Error: COMFYUI_API_URL env var or -comfyui-url flag is required")
	}

	outDirs := strings.Split(*outDirsFlag, ",")
	for i := range outDirs {
		outDirs[i] = strings.TrimSpace(outDirs[i])
	}

	// Read English deck for prompt words
	d, err := readDeck(*englishDeckPath)
	if err != nil {
		log.Fatalf("Read deck: %v", err)
	}

	// Create ComfyUI client
	var imgGen image.Generator
	if !*dryRun {
		cfID := os.Getenv("CF_ACCESS_CLIENT_ID")
		cfSecret := os.Getenv("CF_ACCESS_CLIENT_SECRET")
		opts := []image.ComfyUIOption{image.WithComfyJobTimeout(*timeout)}
		switch *workflowType {
		case "flux-dev":
			// Local Flux Dev via UNETLoader + DualCLIPLoader + VAELoader
			opts = append(opts,
				image.WithComfyWorkflow(image.FluxDevWorkflow()),
				image.WithComfyNodeRoles(image.FluxDevNodeRoles()),
			)
		case "pony", "sd":
			// Pony SDXL or SD1.5 via CheckpointLoaderSimple
			opts = append(opts,
				image.WithComfyWorkflow(image.SDWorkflow()),
				image.WithComfyNodeRoles(image.SDCardNodeRoles()),
			)
		}
		if *checkpoint != "" {
			opts = append(opts, image.WithComfyCheckpoint(*checkpoint))
		}
		imgGen = image.NewComfyUIClient(url, cfID, cfSecret, opts...)
	}

	// Select prompt template: pony/sd → booru-tag style; flux → natural language.
	tpl := fluxPromptTemplate
	if *workflowType == "pony" || *workflowType == "sd" {
		tpl = ponyPromptTemplate
	}
	if *promptFlag != "" {
		tpl = *promptFlag
	}

	fmt.Printf("Workflow: %s\n", *workflowType)
	fmt.Printf("Prompt template: %s\n", tpl)

	fmt.Printf("Regenerating images for %d cards\n", len(d.Cards))
	fmt.Printf("Output dirs: %s\n\n", strings.Join(outDirs, ", "))

	ok, skipped, failed := 0, 0, 0

	for i, c := range d.Cards {
		cardIndex := i + 1

		// Determine image filename from backText (Czech word) — same convention as generator.go
		filename := storage.BuildMediaFilename(cardIndex, c.BackText, "image", "png")

		// Check if file already exists in all output dirs
		if !*force {
			allExist := true
			for _, dir := range outDirs {
				if _, err := os.Stat(filepath.Join(dir, filename)); err != nil {
					allExist = false
					break
				}
			}
			if allExist {
				fmt.Printf("  [%d/%d] %s (%s): exists, skipping\n", cardIndex, len(d.Cards), c.FrontText, filename)
				skipped++
				continue
			}
		}

		prompt := fmt.Sprintf(tpl, c.FrontText)
		fmt.Printf("  [%d/%d] %s → %s\n    prompt: %q\n", cardIndex, len(d.Cards), c.FrontText, filename, prompt)

		if *dryRun {
			ok++
			continue
		}

		imgData, err := imgGen.GenerateImage(prompt)
		if err != nil {
			fmt.Printf("    ERROR: %v\n", err)
			failed++
			continue
		}

		// Write to all output directories
		writeErr := false
		for _, dir := range outDirs {
			if err := os.MkdirAll(dir, 0755); err != nil {
				fmt.Printf("    ERROR mkdir %s: %v\n", dir, err)
				writeErr = true
				continue
			}
			dest := filepath.Join(dir, filename)
			if err := os.WriteFile(dest, imgData, 0644); err != nil {
				fmt.Printf("    ERROR write %s: %v\n", dest, err)
				writeErr = true
			} else {
				fmt.Printf("    saved: %s\n", dest)
			}
		}
		if !writeErr {
			ok++
		} else {
			failed++
		}
	}

	fmt.Printf("\n=== Done ===\n")
	fmt.Printf("Generated: %d  Skipped: %d  Failed: %d\n", ok, skipped, failed)
	if failed > 0 {
		os.Exit(1)
	}
}

func readDeck(path string) (*deck, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var d deck
	return &d, json.Unmarshal(data, &d)
}
