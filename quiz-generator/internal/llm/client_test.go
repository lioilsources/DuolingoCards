package llm

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestCompleteVisionSendsMultimodalContent(t *testing.T) {
	var gotBody map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		body, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(body, &gotBody)
		w.Header().Set("Content-Type", "application/json")
		io.WriteString(w, `{"choices":[{"message":{"content":"{\"score\":9}"}}]}`)
	}))
	defer srv.Close()

	c := NewClient(srv.URL, "qwen-vl")
	png := []byte("\x89PNG\r\n\x1a\nrest-of-image")
	got, err := c.CompleteVision(context.Background(), "system", "describe", png)
	if err != nil {
		t.Fatal(err)
	}
	if got != `{"score":9}` {
		t.Fatalf("unexpected reply: %q", got)
	}

	// The user message must carry a multimodal content array with a PNG data URI.
	msgs, ok := gotBody["messages"].([]any)
	if !ok || len(msgs) != 2 {
		t.Fatalf("messages malformed: %v", gotBody["messages"])
	}
	user := msgs[1].(map[string]any)
	parts, ok := user["content"].([]any)
	if !ok || len(parts) != 2 {
		t.Fatalf("user content is not a 2-part array: %v", user["content"])
	}
	img := parts[1].(map[string]any)
	if img["type"] != "image_url" {
		t.Fatalf("second part is not image_url: %v", img)
	}
	url := img["image_url"].(map[string]any)["url"].(string)
	if !strings.HasPrefix(url, "data:image/png;base64,") {
		t.Fatalf("image url not a png data URI: %q", url)
	}
}

func TestSniffMIME(t *testing.T) {
	cases := map[string]string{
		"image/png":  "\x89PNG\r\n\x1a\n....",
		"image/jpeg": "\xFF\xD8\xFF\xE0xxxx",
	}
	for want, b := range cases {
		if got := sniffMIME([]byte(b)); got != want {
			t.Errorf("sniffMIME(%q) = %s, want %s", b, got, want)
		}
	}
	if got := sniffMIME([]byte("RIFF????WEBPxxxx")); got != "image/webp" {
		t.Errorf("webp sniff failed: %s", got)
	}
}
