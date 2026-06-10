// Package translate generates i18n YAML files for a deck using an LLM.
// It reads the pivot i18n file (cs) and translates one card at a time to
// stay well within token limits and Cloudflare's 100 s gateway timeout.
package translate

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

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
Return ONLY a valid JSON object: {"label":"...","summary":"...","info":"..."}`

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

	// Translate deck title if missing.
	if existing.Title == "" || force {
		title, err := translateTitle(ctx, client, pivot.Title, targetLang)
		if err != nil {
			return "", fmt.Errorf("title for %s: %w", targetLang.Code, err)
		}
		existing.Title = title
	}

	// Translate each card individually.
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
	}

	existing.Lang = targetLang.Code

	// Write YAML.
	if err := os.MkdirAll(filepath.Dir(outPath), 0755); err != nil {
		return "", fmt.Errorf("mkdir: %w", err)
	}
	f, err := os.Create(outPath)
	if err != nil {
		return "", fmt.Errorf("create %s: %w", outPath, err)
	}
	defer f.Close()
	enc := yaml.NewEncoder(f)
	enc.SetIndent(2)
	if err := enc.Encode(existing); err != nil {
		return "", fmt.Errorf("write YAML: %w", err)
	}
	return outPath, nil
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
	raw, err := client.Complete(ctx, systemPrompt, user)
	if err != nil {
		return content.CardI18n{}, err
	}

	raw = strings.TrimSpace(raw)
	if start := strings.Index(raw, "{"); start >= 0 {
		if end := strings.LastIndex(raw, "}"); end > start {
			raw = raw[start : end+1]
		}
	}

	var ci content.CardI18n
	if err := json.Unmarshal([]byte(raw), &ci); err != nil {
		return content.CardI18n{}, fmt.Errorf("parse JSON: %w\nraw: %s", err, raw)
	}
	return ci, nil
}
