package content

import "testing"

func TestTunedRoundTrip(t *testing.T) {
	dir := t.TempDir()
	style := "pony-cartoon"

	// Missing file → empty map, no error.
	got, err := LoadTuned(dir, style)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 0 {
		t.Fatalf("want empty, got %v", got)
	}

	// Save two cards.
	if err := SaveTuned(dir, style, "animal.lion", TunedEntry{Positive: "a lion", Seed: 11, Score: 9}); err != nil {
		t.Fatal(err)
	}
	if err := SaveTuned(dir, style, "animal.bee", TunedEntry{Positive: "a bee", Negative: "no text", Seed: 22}); err != nil {
		t.Fatal(err)
	}

	got, err = LoadTuned(dir, style)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 2 {
		t.Fatalf("want 2 entries, got %d", len(got))
	}
	if got["animal.lion"].Seed != 11 || got["animal.lion"].Positive != "a lion" {
		t.Fatalf("lion entry wrong: %+v", got["animal.lion"])
	}
	if got["animal.bee"].Negative != "no text" {
		t.Fatalf("bee entry wrong: %+v", got["animal.bee"])
	}

	// Upsert one card preserves the other.
	if err := SaveTuned(dir, style, "animal.lion", TunedEntry{Positive: "a majestic lion", Seed: 99}); err != nil {
		t.Fatal(err)
	}
	got, err = LoadTuned(dir, style)
	if err != nil {
		t.Fatal(err)
	}
	if got["animal.lion"].Seed != 99 || got["animal.lion"].Positive != "a majestic lion" {
		t.Fatalf("lion not updated: %+v", got["animal.lion"])
	}
	if _, ok := got["animal.bee"]; !ok {
		t.Fatalf("bee entry lost after upsert")
	}
}
