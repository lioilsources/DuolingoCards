package imagetune

import "testing"

func TestExtractJSON(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
		err  bool
	}{
		{"plain", `{"score":9}`, `{"score":9}`, false},
		{"code fence", "```json\n{\"score\":7,\"pass\":false}\n```", `{"score":7,"pass":false}`, false},
		{"prose prefix", "Sure! Here is the result:\n{\"a\":1}", `{"a":1}`, false},
		{"nested", `prefix {"a":{"b":2},"c":3} suffix`, `{"a":{"b":2},"c":3}`, false},
		{"brace in string", `{"s":"a}b","n":1}`, `{"s":"a}b","n":1}`, false},
		{"none", "no json here", "", true},
		{"unbalanced", `{"a":1`, "", true},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			got, err := extractJSON(c.in)
			if c.err {
				if err == nil {
					t.Fatalf("want error, got %q", got)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if got != c.want {
				t.Fatalf("got %q want %q", got, c.want)
			}
		})
	}
}
