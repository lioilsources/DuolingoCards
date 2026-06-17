// Package translate generates i18n YAML files for a deck using an LLM.
// It reads the pivot i18n file (cs) and translates one card at a time to
// stay well within token limits.
package translate

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/langs"
	"github.com/duolingocards/quiz-generator/internal/llm"
	"gopkg.in/yaml.v3"
)

const systemPrompt = `You are a professional translator and lexicographer specialising in educational flashcard content.
Translate accurately and naturally. Rules:
- label: standard translation of the word/term, 1-3 words max
- summary: one clear sentence, same factual meaning as the source
- info: 2-3 sentences, same facts as the source, fluid prose
Do NOT add or remove facts. Do NOT transliterate — translate.
Return ONLY a valid JSON object with string values: {"label":"...","summary":"...","info":"..."}`

// cardSchema is the JSON Schema used for guided decoding of card translations.
var cardSchema = map[string]any{
	"type": "object",
	"properties": map[string]any{
		"label":   map[string]any{"type": "string"},
		"summary": map[string]any{"type": "string"},
		"info":    map[string]any{"type": "string"},
	},
	"required":             []string{"label", "summary", "info"},
	"additionalProperties": false,
}

// Translate generates a target-language i18n file for the given deck.
// Each card is translated in a separate LLM call to stay within token limits.
// Cards already present in an existing file are skipped unless force=true.
// Returns the path written.
func Translate(ctx context.Context, client *llm.Client, d *content.Deck, targetLang langs.Target, force bool) (string, error) {
	outPath := filepath.Join(d.Dir, "i18n", targetLang.Code+".yaml")

	// Load existing file for incremental / resume.
	existing := content.I18nFile{}
	if !force {
		if data, err := os.ReadFile(outPath); err == nil {
			_ = yaml.Unmarshal(data, &existing)
		}
	}

	pivotLang := d.PivotLang()
	if pivotLang == "" {
		return "", fmt.Errorf("deck %q has no pivot language", d.Meta.Slug)
	}
	pivot := d.I18n[pivotLang]

	if existing.Cards == nil {
		existing.Cards = map[string]content.CardI18n{}
	}

	existing.Lang = targetLang.Code

	if err := os.MkdirAll(filepath.Dir(outPath), 0755); err != nil {
		return "", fmt.Errorf("mkdir: %w", err)
	}

	// Translate deck title if missing.
	if existing.Title == "" || force {
		title, err := translateTitle(ctx, client, pivot.Title, targetLang)
		if err != nil {
			return "", fmt.Errorf("title for %s: %w", targetLang.Code, err)
		}
		existing.Title = title
		if err := writeI18n(outPath, existing); err != nil {
			return "", err
		}
	}

	// Translate each card individually, persisting after each one so a restart
	// can resume from where it left off.
	for _, c := range d.Meta.Cards {
		if !force {
			if ci, ok := existing.Cards[c.Key]; ok && ci.Label != "" && ci.Summary != "" && ci.Info != "" {
				continue
			}
		}
		pc := pivot.Cards[c.Key]
		ci, err := translateCard(ctx, client, c.Hint, pc, targetLang)
		if err != nil {
			return "", fmt.Errorf("card %s for %s: %w", c.Key, targetLang.Code, err)
		}
		existing.Cards[c.Key] = ci
		if err := writeI18n(outPath, existing); err != nil {
			return "", err
		}
	}

	return outPath, nil
}

// sanitizeLine collapses all whitespace (tabs, newlines, runs of spaces) into
// single spaces. Used for label and summary which must be single-line.
func sanitizeLine(s string) string {
	return strings.Join(strings.Fields(s), " ")
}

// sanitizeBlock removes tabs and carriage returns but preserves intentional
// newlines. Used for info which may span multiple sentences.
func sanitizeBlock(s string) string {
	s = strings.ReplaceAll(s, "\t", " ")
	s = strings.ReplaceAll(s, "\r", "")
	return strings.TrimSpace(s)
}

func writeI18n(path string, f content.I18nFile) error {
	out, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("create %s: %w", path, err)
	}
	defer out.Close()
	enc := yaml.NewEncoder(out)
	enc.SetIndent(2)
	if err := enc.Encode(f); err != nil {
		return fmt.Errorf("write YAML: %w", err)
	}
	return nil
}

func translateTitle(ctx context.Context, client *llm.Client, csTitle string, t langs.Target) (string, error) {
	user := fmt.Sprintf("Translate this flashcard deck title from Czech into %s (%s). Return only the translated title, nothing else.\n\nTitle: %s", t.Name, t.Code, csTitle)
	result, err := client.Complete(ctx, "You are a professional translator. Translate accurately and naturally.", user)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(result), nil
}

func translateCard(ctx context.Context, client *llm.Client, hint string, pc content.CardI18n, t langs.Target) (content.CardI18n, error) {
	input := map[string]string{
		"hint":    hint,
		"label":   pc.Label,
		"summary": pc.Summary,
		"info":    strings.TrimSpace(pc.Info),
	}
	inputJSON, _ := json.Marshal(input)

	user := fmt.Sprintf(
		"Translate this flashcard from Czech into %s (%s).\n\nSource:\n%s",
		t.Name, t.Code, inputJSON,
	)

	const maxAttempts = 3
	var lastErr error
	for attempt := 0; attempt < maxAttempts; attempt++ {
		if attempt > 0 {
			select {
			case <-ctx.Done():
				return content.CardI18n{}, ctx.Err()
			case <-time.After(time.Duration(attempt*2) * time.Second):
			}
		}
		raw, err := client.CompleteJSON(ctx, systemPrompt, user, "card_translation", cardSchema)
		if err != nil {
			lastErr = err
			continue
		}
		var ci content.CardI18n
		if err := json.Unmarshal([]byte(raw), &ci); err != nil {
			lastErr = fmt.Errorf("parse JSON: %w\nraw: %s", err, raw)
			continue
		}
		ci.Label = sanitizeLine(ci.Label)
		ci.Summary = sanitizeLine(ci.Summary)
		ci.Info = sanitizeBlock(ci.Info)
		return ci, nil
	}
	return content.CardI18n{}, lastErr
}
