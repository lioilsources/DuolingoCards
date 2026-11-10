package main

import (
	"bytes"
	"context"
	"crypto/sha1"
	_ "embed"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png"
	"math/rand"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/duolingocards/quiz-generator/internal/comfyuiimage"
	"github.com/duolingocards/quiz-generator/internal/content"
	"github.com/duolingocards/quiz-generator/internal/imagegen"
	"github.com/duolingocards/quiz-generator/internal/prompt"
)

//go:embed review.html
var reviewPage []byte

// runReview serves a local page for going through every card image at once:
// flag the bad ones, edit the prompt that produced them and regenerate. A
// regenerated image lands as a *candidate* next to the current one and only
// replaces it on Accept, which also writes the prompt + seed into the tuned
// sidecar so `content images` reproduces it. Nothing here publishes — run
// `make ship DECK=<slug>` afterwards.
//
// State lives under -state (default build/review, git-ignored):
//
//	state.json                         flags per deck/style/card
//	candidates/<slug>/<style>/<image>  pending regenerations (+ .json prompt)
//	replaced/<slug>/<style>/…          the images Accept replaced
//	thumbs/                            downscaled previews for the grid
func runReview(args []string) error {
	fs := newFlagSet("review")
	decksDir := fs.String("decks", "decks", "root folder of deck-per-folder subfolders")
	addr := fs.String("addr", "127.0.0.1:8790", "listen address")
	comfyURL := fs.String("url", "http://spark-99bb:8188", "ComfyUI server base URL")
	stateDir := fs.String("state", "build/review", "review state: flags, candidates, replaced images, thumbnails")
	workers := fs.Int("workers", 2, "parallel generations sent to ComfyUI")
	ponyCheckpoint := fs.String("pony-checkpoint", "ponyDiffusionV6XL_v6StartWithThisOne.safetensors", "Pony SDXL checkpoint for img2img restyle styles")
	illustriousCheckpoint := fs.String("illustrious-checkpoint", "Illustrious-XL-v2.0.safetensors", "Illustrious checkpoint for ControlNet restyle styles")
	controlNetModel := fs.String("controlnet", "controlnet-union-sdxl-promax-xinsir.safetensors", "SDXL ControlNet model for the ControlNet restyle styles")
	if err := fs.Parse(args); err != nil {
		return err
	}

	decks, err := loadDecks(*decksDir)
	if err != nil {
		return err
	}
	rv := &reviewer{
		decks:     map[string]*content.Deck{},
		stateDir:  *stateDir,
		comfyURL:  *comfyURL,
		sem:       make(chan struct{}, *workers),
		pony:      comfyuiimage.NewClient(*comfyURL, "", ""),
		flux:      comfyuiimage.NewClient(*comfyURL, "", "", comfyuiimage.WithFluxDev()),
		restylers: newRestyleClients(*comfyURL, *ponyCheckpoint, *illustriousCheckpoint, *controlNetModel),
		flags:     map[string]string{},
	}
	for _, d := range decks {
		rv.decks[d.Meta.Slug] = d
		rv.order = append(rv.order, d.Meta.Slug)
	}
	if err := rv.loadState(); err != nil {
		return err
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Write(reviewPage)
	})
	mux.HandleFunc("/api/decks", rv.handleDecks)
	mux.HandleFunc("/api/card", rv.handleCard)
	mux.HandleFunc("/api/generate", rv.handleGenerate)
	mux.HandleFunc("/api/accept", rv.handleAccept)
	mux.HandleFunc("/api/discard", rv.handleDiscard)
	mux.HandleFunc("/api/flag", rv.handleFlag)
	mux.HandleFunc("/img/", rv.handleImage)

	fmt.Printf("review: http://%s  (ComfyUI %s, state %s)\n", *addr, *comfyURL, *stateDir)
	return http.ListenAndServe(*addr, mux)
}

type reviewer struct {
	decks     map[string]*content.Deck
	order     []string
	stateDir  string
	comfyURL  string
	sem       chan struct{}
	pony      *comfyuiimage.Client // text-to-image Pony (pony-cartoon)
	flux      *comfyuiimage.Client
	restylers map[prompt.Backend]*comfyuiimage.Client

	mu    sync.Mutex        // guards flags, state.json, candidates, tuned sidecars
	flags map[string]string // "slug/style/key" → unsafe | stale | ok
}

// reviewParams is the prompt a cell was (or is to be) rendered with.
type reviewParams struct {
	Positive        string  `json:"positive"`
	Negative        string  `json:"negative"`
	Seed            int64   `json:"seed"`
	Denoise         float64 `json:"denoise,omitempty"`
	ControlStrength float64 `json:"controlStrength,omitempty"`
	ControlEnd      float64 `json:"controlEnd,omitempty"`
}

func flagKey(slug, style, key string) string { return slug + "/" + style + "/" + key }

func (rv *reviewer) loadState() error {
	raw, err := os.ReadFile(filepath.Join(rv.stateDir, "state.json"))
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return err
	}
	var st struct {
		Flags map[string]string `json:"flags"`
	}
	if err := json.Unmarshal(raw, &st); err != nil {
		return fmt.Errorf("parse review state: %w", err)
	}
	if st.Flags != nil {
		rv.flags = st.Flags
	}
	return nil
}

// saveState writes state.json; callers hold rv.mu.
func (rv *reviewer) saveState() error {
	if err := os.MkdirAll(rv.stateDir, 0755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(map[string]any{"flags": rv.flags}, "", "  ")
	if err != nil {
		return err
	}
	tmp := filepath.Join(rv.stateDir, ".state.json.tmp")
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return err
	}
	return os.Rename(tmp, filepath.Join(rv.stateDir, "state.json"))
}

func (rv *reviewer) setFlag(slug, style, key, flag string) {
	k := flagKey(slug, style, key)
	if flag == "" {
		delete(rv.flags, k)
	} else {
		rv.flags[k] = flag
	}
}

// diskStyles lists the style folders under decks/<slug>/images/.
func diskStyles(d *content.Deck) []string {
	entries, _ := os.ReadDir(filepath.Join(d.Dir, "images"))
	var out []string
	for _, e := range entries {
		if e.IsDir() && !strings.HasPrefix(e.Name(), ".") {
			out = append(out, e.Name())
		}
	}
	sort.Strings(out)
	return out
}

// cardLabel is the label in lang, else the pivot's — the reviewer reads it to
// judge whether the image shows the right thing.
func cardLabel(d *content.Deck, key, lang string) string {
	for _, lang := range []string{lang, d.PivotLang()} {
		if f, ok := d.I18n[lang]; ok {
			if ci, ok := f.Cards[key]; ok && ci.Label != "" {
				return ci.Label
			}
		}
	}
	return ""
}

func (rv *reviewer) candidatePath(d *content.Deck, style, image string) string {
	return filepath.Join(rv.stateDir, "candidates", d.Meta.Slug, style, image)
}

func fileVersion(path string) int64 {
	info, err := os.Stat(path)
	if err != nil || info.Size() == 0 {
		return 0
	}
	return info.ModTime().UnixNano()
}

func (rv *reviewer) handleDecks(w http.ResponseWriter, r *http.Request) {
	type cell struct {
		Version   int64  `json:"v"`    // image mtime, 0 = missing
		Candidate int64  `json:"cand"` // candidate mtime, 0 = none
		Flag      string `json:"flag,omitempty"`
	}
	type card struct {
		Key     string          `json:"key"`
		Image   string          `json:"image"`
		Label   string          `json:"label"` // Czech, the reviewer's language
		LabelEn string          `json:"labelEn"`
		Hint    string          `json:"hint"`
		Styles  map[string]cell `json:"styles"`
	}
	type deck struct {
		Slug     string   `json:"slug"`
		Declared []string `json:"declared"`
		OnDisk   []string `json:"onDisk"`
		Cards    []card   `json:"cards"`
	}
	rv.mu.Lock()
	defer rv.mu.Unlock()
	var out []deck
	for _, slug := range rv.order {
		d := rv.decks[slug]
		dk := deck{Slug: slug, Declared: d.Meta.Styles, OnDisk: diskStyles(d)}
		for _, c := range d.Meta.Cards {
			if c.Image == "" {
				continue
			}
			cd := card{Key: c.Key, Image: c.Image, Label: cardLabel(d, c.Key, "cs"), LabelEn: cardLabel(d, c.Key, "en"), Hint: c.Hint, Styles: map[string]cell{}}
			for _, s := range dk.OnDisk {
				cd.Styles[s] = cell{
					Version:   fileVersion(filepath.Join(d.Dir, "images", s, c.Image)),
					Candidate: fileVersion(rv.candidatePath(d, s, c.Image)),
					Flag:      rv.flags[flagKey(slug, s, c.Key)],
				}
			}
			dk.Cards = append(dk.Cards, cd)
		}
		out = append(out, dk)
	}
	writeJSON(w, out)
}

// lookup resolves deck/card/style from a request and checks the style is one
// the pipeline can render.
func (rv *reviewer) lookup(slug, key, style string) (*content.Deck, content.CardYAML, prompt.Style, error) {
	d, ok := rv.decks[slug]
	if !ok {
		return nil, content.CardYAML{}, prompt.Style{}, fmt.Errorf("unknown deck %q", slug)
	}
	for _, c := range d.Meta.Cards {
		if c.Key == key {
			st, ok := prompt.DefaultStyles[style]
			if !ok {
				return nil, content.CardYAML{}, prompt.Style{}, fmt.Errorf("style %q is not generated by the pipeline", style)
			}
			return d, c, st, nil
		}
	}
	return nil, content.CardYAML{}, prompt.Style{}, fmt.Errorf("unknown card %q in %s", key, slug)
}

// currentParams is the prompt `content images` would use for the cell: the
// tuned sidecar entry when there is one, else the brief expanded for the style.
func currentParams(d *content.Deck, c content.CardYAML, style string, st prompt.Style) (reviewParams, string, error) {
	b, _, err := briefFor(c, d, style)
	if err != nil {
		return reviewParams{}, "", err
	}
	p, err := prompt.ExpandByName(b, style)
	if err != nil {
		return reviewParams{}, "", err
	}
	rp := reviewParams{Positive: p.Positive, Negative: p.Negative}
	if st.Img2Img {
		rp.Denoise = st.Denoise
		if st.ControlNet {
			rp.ControlStrength = st.ControlStrength
			rp.ControlEnd = st.ControlEnd
		}
	}
	source := "brief"
	tuned, err := content.LoadTuned(d.Dir, style)
	if err != nil {
		return reviewParams{}, "", err
	}
	if e, ok := tuned[c.Key]; ok {
		source = "tuned"
		rp.Positive, rp.Negative, rp.Seed = e.Positive, e.Negative, e.Seed
		if e.Denoise > 0 {
			rp.Denoise = e.Denoise
		}
		if e.ControlStrength > 0 {
			rp.ControlStrength = e.ControlStrength
		}
		if e.ControlEnd > 0 {
			rp.ControlEnd = e.ControlEnd
		}
	}
	return rp, source, nil
}

func (rv *reviewer) handleCard(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	d, c, st, err := rv.lookup(q.Get("deck"), q.Get("card"), q.Get("style"))
	if err != nil {
		httpError(w, http.StatusBadRequest, err)
		return
	}
	style := q.Get("style")
	cur, source, err := currentParams(d, c, style, st)
	if err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	resp := map[string]any{
		"deck": d.Meta.Slug, "card": c.Key, "style": style,
		"label": cardLabel(d, c.Key, "cs"), "hint": c.Hint, "brief": c.Brief,
		"backend": st.Backend, "img2img": st.Img2Img, "baseStyle": st.BaseStyle, "controlNet": st.ControlNet,
		"current": cur, "source": source,
	}
	// The brief expanded fresh, so an edited/tuned prompt can be reset to it.
	if b, _, err := briefFor(c, d, style); err == nil {
		if p, err := prompt.ExpandByName(b, style); err == nil {
			resp["fromBrief"] = reviewParams{Positive: p.Positive, Negative: p.Negative,
				Denoise: st.Denoise, ControlStrength: st.ControlStrength, ControlEnd: st.ControlEnd}
		}
	}
	rv.mu.Lock()
	if cp, err := readCandidateParams(rv.candidatePath(d, style, c.Image)); err == nil {
		resp["candidate"] = cp
	}
	rv.mu.Unlock()
	writeJSON(w, resp)
}

func readCandidateParams(imgPath string) (reviewParams, error) {
	var p reviewParams
	raw, err := os.ReadFile(imgPath + ".json")
	if err != nil {
		return p, err
	}
	err = json.Unmarshal(raw, &p)
	return p, err
}

type cellRequest struct {
	Deck  string `json:"deck"`
	Card  string `json:"card"`
	Style string `json:"style"`
}

func (rv *reviewer) handleGenerate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		cellRequest
		reviewParams
	}
	if !decodePost(w, r, &req) {
		return
	}
	d, c, st, err := rv.lookup(req.Deck, req.Card, req.Style)
	if err != nil {
		httpError(w, http.StatusBadRequest, err)
		return
	}
	p := req.reviewParams
	if p.Seed == 0 {
		// Pick the seed here rather than letting the client do it, so the
		// candidate's seed is known and Accept can record it.
		p.Seed = rand.Int63n(1<<53) + 1
	}

	select {
	case rv.sem <- struct{}{}:
	case <-r.Context().Done():
		return
	}
	img, err := rv.render(r.Context(), d, c, req.Style, st, p)
	<-rv.sem
	if err != nil {
		httpError(w, http.StatusBadGateway, err)
		return
	}

	rv.mu.Lock()
	defer rv.mu.Unlock()
	path := rv.candidatePath(d, req.Style, c.Image)
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	meta, _ := json.MarshalIndent(p, "", "  ")
	if err := os.WriteFile(path, img, 0644); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	if err := os.WriteFile(path+".json", meta, 0644); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	writeJSON(w, map[string]any{"candidate": p, "cand": fileVersion(path)})
}

// render runs one generation the same way `content images` does.
func (rv *reviewer) render(ctx context.Context, d *content.Deck, c content.CardYAML, style string, st prompt.Style, p reviewParams) ([]byte, error) {
	prefix := imageFilenamePrefix(d.Meta.Slug, c.Key, style)
	if st.Img2Img {
		client, ok := rv.restylers[st.Backend]
		if !ok {
			return nil, fmt.Errorf("no restyle client for backend %q", st.Backend)
		}
		base, err := os.ReadFile(filepath.Join(d.Dir, "images", st.BaseStyle, c.Image))
		if err != nil {
			return nil, fmt.Errorf("read %s base: %w", st.BaseStyle, err)
		}
		keyPart := c.Key[strings.LastIndex(c.Key, ".")+1:]
		req := comfyuiimage.Img2ImgRequest{
			BaseImage:      base,
			BaseFilename:   fmt.Sprintf("restyle-%s-%s.png", d.Meta.Slug, keyPart),
			Prompt:         p.Positive,
			NegativePrompt: p.Negative,
			FilenamePrefix: prefix,
			Denoise:        p.Denoise,
			Seed:           p.Seed,
		}
		if st.ControlNet {
			req.ControlStrength = p.ControlStrength
			req.ControlEnd = p.ControlEnd
		}
		return client.GenerateImg2Img(ctx, req)
	}
	client := rv.pony
	if st.Backend == prompt.BackendFlux {
		client = rv.flux
	}
	resp, err := client.Generate(ctx, imagegen.GenerateRequest{
		Prompt:         p.Positive,
		NegativePrompt: p.Negative,
		N:              1,
		AspectRatio:    "1:1",
		Resolution:     "1k",
		ResponseFormat: "b64_json",
		Seed:           p.Seed,
		FilenamePrefix: prefix,
	})
	if err != nil {
		return nil, err
	}
	return resp.Data[0].Bytes()
}

func (rv *reviewer) handleAccept(w http.ResponseWriter, r *http.Request) {
	var req cellRequest
	if !decodePost(w, r, &req) {
		return
	}
	d, c, st, err := rv.lookup(req.Deck, req.Card, req.Style)
	if err != nil {
		httpError(w, http.StatusBadRequest, err)
		return
	}
	rv.mu.Lock()
	defer rv.mu.Unlock()
	cand := rv.candidatePath(d, req.Style, c.Image)
	p, err := readCandidateParams(cand)
	if err != nil {
		httpError(w, http.StatusConflict, fmt.Errorf("no candidate to accept"))
		return
	}
	dst := filepath.Join(d.Dir, "images", req.Style, c.Image)
	if fileVersion(dst) > 0 {
		old := filepath.Join(rv.stateDir, "replaced", d.Meta.Slug, req.Style,
			time.Now().Format("20060102-150405")+"-"+c.Image)
		if err := os.MkdirAll(filepath.Dir(old), 0755); err != nil {
			httpError(w, http.StatusInternalServerError, err)
			return
		}
		if err := copyFile(dst, old); err != nil {
			httpError(w, http.StatusInternalServerError, err)
			return
		}
	}
	if err := copyFile(cand, dst); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	os.Remove(cand)
	os.Remove(cand + ".json")

	entry := content.TunedEntry{
		Positive:  p.Positive,
		Negative:  p.Negative,
		Seed:      p.Seed,
		Model:     "review",
		UpdatedAt: time.Now().UTC().Format(time.RFC3339),
	}
	if st.Img2Img && p.Denoise != st.Denoise {
		entry.Denoise = p.Denoise
	}
	if st.ControlNet {
		if p.ControlStrength != st.ControlStrength {
			entry.ControlStrength = p.ControlStrength
		}
		if p.ControlEnd != st.ControlEnd {
			entry.ControlEnd = p.ControlEnd
		}
	}
	if err := content.SaveTuned(d.Dir, req.Style, c.Key, entry); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}

	rv.setFlag(d.Meta.Slug, req.Style, c.Key, "ok")
	// A new base invalidates every restyle painted over the old one.
	var stale []string
	for _, s := range diskStyles(d) {
		if ds, ok := prompt.DefaultStyles[s]; ok && ds.Img2Img && ds.BaseStyle == req.Style {
			rv.setFlag(d.Meta.Slug, s, c.Key, "stale")
			stale = append(stale, s)
		}
	}
	if err := rv.saveState(); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	writeJSON(w, map[string]any{"v": fileVersion(dst), "stale": stale})
}

func (rv *reviewer) handleDiscard(w http.ResponseWriter, r *http.Request) {
	var req cellRequest
	if !decodePost(w, r, &req) {
		return
	}
	d, c, _, err := rv.lookup(req.Deck, req.Card, req.Style)
	if err != nil {
		httpError(w, http.StatusBadRequest, err)
		return
	}
	rv.mu.Lock()
	defer rv.mu.Unlock()
	cand := rv.candidatePath(d, req.Style, c.Image)
	os.Remove(cand)
	os.Remove(cand + ".json")
	writeJSON(w, map[string]any{})
}

func (rv *reviewer) handleFlag(w http.ResponseWriter, r *http.Request) {
	var req struct {
		cellRequest
		Flag string `json:"flag"`
	}
	if !decodePost(w, r, &req) {
		return
	}
	switch req.Flag {
	case "", "unsafe", "stale", "ok":
	default:
		httpError(w, http.StatusBadRequest, fmt.Errorf("unknown flag %q", req.Flag))
		return
	}
	if _, ok := rv.decks[req.Deck]; !ok {
		httpError(w, http.StatusBadRequest, fmt.Errorf("unknown deck %q", req.Deck))
		return
	}
	rv.mu.Lock()
	defer rv.mu.Unlock()
	rv.setFlag(req.Deck, req.Style, req.Card, req.Flag)
	if err := rv.saveState(); err != nil {
		httpError(w, http.StatusInternalServerError, err)
		return
	}
	writeJSON(w, map[string]any{})
}

// handleImage serves /img/<slug>/<style>/<image>; ?cand=1 serves the candidate,
// ?thumb=1 a cached 384px JPEG (the PNG masters are ~1 MB each and the grid
// shows over a thousand of them).
func (rv *reviewer) handleImage(w http.ResponseWriter, r *http.Request) {
	parts := strings.Split(strings.TrimPrefix(r.URL.Path, "/img/"), "/")
	if len(parts) != 3 {
		http.NotFound(w, r)
		return
	}
	d, ok := rv.decks[parts[0]]
	style, name := parts[1], parts[2]
	if !ok || strings.Contains(style, "..") || strings.Contains(name, "..") {
		http.NotFound(w, r)
		return
	}
	path := filepath.Join(d.Dir, "images", style, name)
	if r.URL.Query().Get("cand") == "1" {
		path = rv.candidatePath(d, style, name)
	}
	w.Header().Set("Cache-Control", "max-age=31536000, immutable") // URLs carry ?v=<mtime>
	if r.URL.Query().Get("thumb") != "1" {
		http.ServeFile(w, r, path)
		return
	}
	thumb, err := rv.thumbnail(path, 384)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "image/jpeg")
	w.Write(thumb)
}

func (rv *reviewer) thumbnail(path string, size int) ([]byte, error) {
	info, err := os.Stat(path)
	if err != nil {
		return nil, err
	}
	h := sha1.Sum([]byte(fmt.Sprintf("%s|%d|%d|%d", path, info.Size(), info.ModTime().UnixNano(), size)))
	cache := filepath.Join(rv.stateDir, "thumbs", hex.EncodeToString(h[:])+".jpg")
	if data, err := os.ReadFile(cache); err == nil {
		return data, nil
	}
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	src, _, err := image.Decode(f)
	f.Close()
	if err != nil {
		return nil, err
	}
	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, boxDownscale(src, size), &jpeg.Options{Quality: 82}); err != nil {
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(cache), 0755); err == nil {
		os.WriteFile(cache, buf.Bytes(), 0644)
	}
	return buf.Bytes(), nil
}

// boxDownscale shrinks src so its longer side is at most max, averaging every
// source pixel that falls into a destination pixel.
func boxDownscale(src image.Image, max int) image.Image {
	b := src.Bounds()
	sw, sh := b.Dx(), b.Dy()
	if sw <= max && sh <= max {
		return src
	}
	dw, dh := max, sh*max/sw
	if sh > sw {
		dw, dh = sw*max/sh, max
	}
	dst := image.NewRGBA(image.Rect(0, 0, dw, dh))
	for y := 0; y < dh; y++ {
		y0, y1 := y*sh/dh, (y+1)*sh/dh
		for x := 0; x < dw; x++ {
			x0, x1 := x*sw/dw, (x+1)*sw/dw
			var r, g, bl, n uint64
			for sy := y0; sy < y1; sy++ {
				for sx := x0; sx < x1; sx++ {
					cr, cg, cb, _ := src.At(b.Min.X+sx, b.Min.Y+sy).RGBA()
					r, g, bl, n = r+uint64(cr), g+uint64(cg), bl+uint64(cb), n+1
				}
			}
			i := dst.PixOffset(x, y)
			dst.Pix[i+0] = uint8(r / n >> 8)
			dst.Pix[i+1] = uint8(g / n >> 8)
			dst.Pix[i+2] = uint8(bl / n >> 8)
			dst.Pix[i+3] = 255
		}
	}
	return dst
}

func copyFile(src, dst string) error {
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	tmp := dst + ".tmp"
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return err
	}
	return os.Rename(tmp, dst)
}

func decodePost(w http.ResponseWriter, r *http.Request, v any) bool {
	if r.Method != http.MethodPost {
		httpError(w, http.StatusMethodNotAllowed, fmt.Errorf("POST only"))
		return false
	}
	if err := json.NewDecoder(r.Body).Decode(v); err != nil {
		httpError(w, http.StatusBadRequest, err)
		return false
	}
	return true
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}

func httpError(w http.ResponseWriter, code int, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
}
