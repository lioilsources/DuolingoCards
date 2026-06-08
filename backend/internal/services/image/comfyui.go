// Package image provides image generation backends for DuolingoCards.
// ComfyUIClient is an image.Generator backed by a self-hosted ComfyUI server
// running a Flux text-to-image workflow, optionally protected by Cloudflare Access.
//
// Async API flow:
//
//	POST /prompt                → {"prompt_id": "..."}
//	GET  /history/{prompt_id}  → {} until done, then entry with outputs
//	GET  /view?filename=...    → raw image bytes
package image

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strings"
	"time"

	_ "embed"
)

//go:embed workflows/flux_card.json
var defaultComfyWorkflow []byte

//go:embed workflows/sd_card.json
var sdComfyWorkflow []byte

//go:embed workflows/flux_dev.json
var fluxDevWorkflow []byte

// SDWorkflow returns the embedded SD/SDXL-compatible workflow graph.
func SDWorkflow() []byte { return sdComfyWorkflow }

// FluxDevWorkflow returns the workflow for local Flux Dev via UNETLoader + DualCLIPLoader.
func FluxDevWorkflow() []byte { return fluxDevWorkflow }

const (
	comfyPromptPath  = "/prompt"
	comfyHistoryPath = "/history/"
	comfyViewPath    = "/view"

	comfyDefaultPollDelay  = 2 * time.Second
	comfyDefaultJobTimeout = 15 * time.Minute
)

// comfyNodeRoles maps logical roles to node IDs in the workflow graph.
type comfyNodeRoles struct {
	PositivePrompt       string   // node ID of the positive conditioning node
	PositivePromptField  string   // primary field name for the prompt (default: "text")
	PositivePromptExtra  []string // additional fields on the same node to set to the same prompt
	Latent               string   // node ID of the empty latent image node
	Sampler              string   // node ID of the KSampler node
	SaveImage            string   // node ID of the SaveImage node (for output collection)
}

var defaultComfyNodeRoles = comfyNodeRoles{
	PositivePrompt: "6",
	Latent:         "5",
	Sampler:        "3",
	SaveImage:      "9",
}

// fluxDevNodeRoles maps roles for the flux_dev.json workflow (UNETLoader + DualCLIPLoader).
var fluxDevNodeRoles = comfyNodeRoles{
	PositivePrompt:      "4",
	PositivePromptField: "clip_l",
	PositivePromptExtra: []string{"t5xxl"},
	Latent:              "5",
	Sampler:             "6",
	SaveImage:           "8",
}

// sdCardNodeRoles maps roles for the sd_card.json workflow (CheckpointLoaderSimple).
var sdCardNodeRoles = comfyNodeRoles{
	PositivePrompt: "6",
	Latent:         "5",
	Sampler:        "3",
	SaveImage:      "9",
}

// ComfyUIClient implements Generator against a ComfyUI server.
type ComfyUIClient struct {
	baseURL      string
	cfClientID   string
	cfSecret     string
	clientID     string
	httpClient   *http.Client
	maxRetries   int
	pollDelay    time.Duration
	jobTimeout   time.Duration
	workflowJSON []byte
	roles        comfyNodeRoles
	checkpoint   string // optional: overrides node 4 ckpt_name
}

// ComfyUIOption configures the ComfyUIClient.
type ComfyUIOption func(*ComfyUIClient)

// WithComfyJobTimeout sets the maximum time to wait for a ComfyUI job to finish.
func WithComfyJobTimeout(d time.Duration) ComfyUIOption {
	return func(c *ComfyUIClient) { c.jobTimeout = d }
}

// WithComfyWorkflow replaces the embedded workflow graph (API-format JSON).
func WithComfyWorkflow(graph []byte) ComfyUIOption {
	return func(c *ComfyUIClient) { c.workflowJSON = graph }
}

// WithComfyCheckpoint overrides the checkpoint name in node 4 of the workflow.
func WithComfyCheckpoint(name string) ComfyUIOption {
	return func(c *ComfyUIClient) { c.checkpoint = name }
}

// WithComfyNodeRoles overrides the node-ID and field mapping used for workflow injection.
func WithComfyNodeRoles(r comfyNodeRoles) ComfyUIOption {
	return func(c *ComfyUIClient) { c.roles = r }
}

// FluxDevNodeRoles returns node roles for the flux_dev.json workflow.
func FluxDevNodeRoles() comfyNodeRoles { return fluxDevNodeRoles }

// SDCardNodeRoles returns node roles for the sd_card.json workflow.
func SDCardNodeRoles() comfyNodeRoles { return sdCardNodeRoles }

// NewComfyUIClient creates a client for a ComfyUI server. cfClientID and cfSecret
// are Cloudflare Access service-token credentials; pass empty strings for a server
// with no access control.
func NewComfyUIClient(baseURL, cfClientID, cfSecret string, opts ...ComfyUIOption) *ComfyUIClient {
	c := &ComfyUIClient{
		baseURL:      strings.TrimRight(baseURL, "/"),
		cfClientID:   cfClientID,
		cfSecret:     cfSecret,
		clientID:     comfyRandHex(16),
		httpClient:   &http.Client{Timeout: 30 * time.Second},
		maxRetries:   3,
		pollDelay:    comfyDefaultPollDelay,
		jobTimeout:   comfyDefaultJobTimeout,
		workflowJSON: defaultComfyWorkflow,
		roles:        defaultComfyNodeRoles,
	}
	for _, opt := range opts {
		opt(c)
	}
	return c
}

// GenerateImage generates an image for the given prompt and returns the raw PNG bytes.
func (c *ComfyUIClient) GenerateImage(prompt string) ([]byte, error) {
	graph, err := c.buildWorkflow(prompt, 1024, 1024, 1)
	if err != nil {
		return nil, err
	}

	promptID, err := c.submitWithRetry(graph)
	if err != nil {
		return nil, err
	}

	images, err := c.pollUntilDone(promptID)
	if err != nil {
		return nil, err
	}
	if len(images) == 0 {
		return nil, fmt.Errorf("comfyui: no output images for prompt_id %s", promptID)
	}

	return c.downloadImage(images[0])
}

func (c *ComfyUIClient) cfHeaders() map[string]string {
	h := map[string]string{"Content-Type": "application/json"}
	if c.cfClientID != "" {
		h["CF-Access-Client-Id"] = c.cfClientID
	}
	if c.cfSecret != "" {
		h["CF-Access-Client-Secret"] = c.cfSecret
	}
	return h
}

func (c *ComfyUIClient) buildWorkflow(prompt string, w, h, batch int) (map[string]any, error) {
	var graph map[string]any
	if err := json.Unmarshal(c.workflowJSON, &graph); err != nil {
		return nil, fmt.Errorf("parse comfyui workflow: %w", err)
	}

	// Inject prompt — primary field (default "text", Flux uses "clip_l").
	promptField := c.roles.PositivePromptField
	if promptField == "" {
		promptField = "text"
	}
	if err := comfySetNodeInput(graph, c.roles.PositivePrompt, promptField, prompt); err != nil {
		return nil, err
	}
	// Inject into additional fields on the same node (e.g. t5xxl for Flux).
	for _, extraField := range c.roles.PositivePromptExtra {
		if err := comfySetNodeInput(graph, c.roles.PositivePrompt, extraField, prompt); err != nil {
			return nil, err
		}
	}

	if err := comfySetNodeInput(graph, c.roles.Latent, "width", w); err != nil {
		return nil, err
	}
	if err := comfySetNodeInput(graph, c.roles.Latent, "height", h); err != nil {
		return nil, err
	}
	if err := comfySetNodeInput(graph, c.roles.Latent, "batch_size", batch); err != nil {
		return nil, err
	}
	if err := comfySetNodeInput(graph, c.roles.Sampler, "seed", comfyRandSeed()); err != nil {
		return nil, err
	}
	if c.checkpoint != "" {
		if err := comfySetNodeInput(graph, "4", "ckpt_name", c.checkpoint); err != nil {
			return nil, err
		}
	}
	return graph, nil
}

func comfySetNodeInput(graph map[string]any, nodeID, key string, val any) error {
	node, ok := graph[nodeID].(map[string]any)
	if !ok {
		return fmt.Errorf("comfyui workflow node %q not found", nodeID)
	}
	inputs, ok := node["inputs"].(map[string]any)
	if !ok {
		return fmt.Errorf("comfyui workflow node %q has no inputs object", nodeID)
	}
	inputs[key] = val
	return nil
}

func (c *ComfyUIClient) submitWithRetry(graph map[string]any) (string, error) {
	body, err := json.Marshal(map[string]any{
		"prompt":    graph,
		"client_id": c.clientID,
	})
	if err != nil {
		return "", fmt.Errorf("marshal comfyui prompt: %w", err)
	}

	var lastErr error
	for attempt := 0; attempt <= c.maxRetries; attempt++ {
		if attempt > 0 {
			time.Sleep(time.Duration(1<<uint(attempt-1)) * time.Second)
		}
		promptID, err := c.doSubmit(body)
		if err == nil {
			return promptID, nil
		}
		lastErr = err
		// Don't retry 4xx (invalid workflow)
		if isNonRetryable(err) {
			return "", err
		}
	}
	return "", fmt.Errorf("comfyui max retries exceeded: %w", lastErr)
}

func (c *ComfyUIClient) doSubmit(body []byte) (string, error) {
	req, err := http.NewRequest(http.MethodPost, c.baseURL+comfyPromptPath, strings.NewReader(string(body)))
	if err != nil {
		return "", err
	}
	for k, v := range c.cfHeaders() {
		req.Header.Set(k, v)
	}
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("comfyui HTTP request: %w", err)
	}
	defer resp.Body.Close()
	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return "", &comfyAPIError{
			statusCode: resp.StatusCode,
			message:    string(respBody),
			retryable:  resp.StatusCode >= 500,
		}
	}
	var payload struct {
		PromptID   string         `json:"prompt_id"`
		NodeErrors map[string]any `json:"node_errors"`
	}
	if err := json.Unmarshal(respBody, &payload); err != nil {
		return "", fmt.Errorf("decode comfyui prompt response: %w", err)
	}
	if payload.PromptID == "" {
		return "", fmt.Errorf("comfyui returned empty prompt_id (node_errors: %v)", payload.NodeErrors)
	}
	return payload.PromptID, nil
}

type comfyImageRef struct {
	Filename  string `json:"filename"`
	Subfolder string `json:"subfolder"`
	Type      string `json:"type"`
}

type comfyHistoryEntry struct {
	Status struct {
		StatusStr string `json:"status_str"`
		Completed bool   `json:"completed"`
	} `json:"status"`
	Outputs map[string]struct {
		Images []comfyImageRef `json:"images"`
	} `json:"outputs"`
}

func (c *ComfyUIClient) pollUntilDone(promptID string) ([]comfyImageRef, error) {
	deadline := time.Now().Add(c.jobTimeout)
	histURL := c.baseURL + comfyHistoryPath + promptID
	short := promptID
	if len(short) > 8 {
		short = short[:8]
	}
	announced := false

	for {
		if time.Now().After(deadline) {
			return nil, fmt.Errorf("comfyui job %s timed out after %s", promptID, c.jobTimeout)
		}
		time.Sleep(c.pollDelay)

		req, _ := http.NewRequest(http.MethodGet, histURL, nil)
		for k, v := range c.cfHeaders() {
			req.Header.Set(k, v)
		}
		resp, err := c.httpClient.Do(req)
		if err != nil {
			continue
		}
		body, _ := io.ReadAll(resp.Body)
		resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			continue
		}

		var hist map[string]comfyHistoryEntry
		if err := json.Unmarshal(body, &hist); err != nil {
			continue
		}
		entry, ok := hist[promptID]
		if !ok {
			if !announced {
				fmt.Fprintf(os.Stderr, "  [comfyui] job %s: queued/running\n", short)
				announced = true
			}
			continue
		}
		if entry.Status.StatusStr == "error" {
			return nil, fmt.Errorf("comfyui job %s failed", promptID)
		}
		if !entry.Status.Completed {
			continue
		}
		images := comfyCollectImages(entry)
		if len(images) == 0 {
			return nil, fmt.Errorf("comfyui job %s completed with no output images", promptID)
		}
		return images, nil
	}
}

func comfyCollectImages(entry comfyHistoryEntry) []comfyImageRef {
	nodeIDs := make([]string, 0, len(entry.Outputs))
	for id := range entry.Outputs {
		nodeIDs = append(nodeIDs, id)
	}
	sort.Strings(nodeIDs)
	var images []comfyImageRef
	for _, id := range nodeIDs {
		for _, im := range entry.Outputs[id].Images {
			if im.Type != "" && im.Type != "output" {
				continue
			}
			images = append(images, im)
		}
	}
	return images
}

func (c *ComfyUIClient) downloadImage(im comfyImageRef) ([]byte, error) {
	q := url.Values{}
	q.Set("filename", im.Filename)
	q.Set("subfolder", im.Subfolder)
	typ := im.Type
	if typ == "" {
		typ = "output"
	}
	q.Set("type", typ)
	reqURL := c.baseURL + comfyViewPath + "?" + q.Encode()

	dlClient := &http.Client{Timeout: 120 * time.Second}
	req, _ := http.NewRequest(http.MethodGet, reqURL, nil)
	for k, v := range c.cfHeaders() {
		req.Header.Set(k, v)
	}
	resp, err := dlClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("comfyui download image: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("comfyui download image status %d: %s", resp.StatusCode, string(body))
	}
	return io.ReadAll(resp.Body)
}

type comfyAPIError struct {
	statusCode int
	message    string
	retryable  bool
}

func (e *comfyAPIError) Error() string {
	return fmt.Sprintf("comfyui API error %d: %s", e.statusCode, e.message)
}

func isNonRetryable(err error) bool {
	if e, ok := err.(*comfyAPIError); ok {
		return !e.retryable
	}
	return false
}

func comfyRandSeed() int64 {
	max := new(big.Int).Lsh(big.NewInt(1), 63)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return time.Now().UnixNano()
	}
	return n.Int64()
}

func comfyRandHex(nbytes int) string {
	b := make([]byte, nbytes)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("%x", time.Now().UnixNano())
	}
	return fmt.Sprintf("%x", b)
}
