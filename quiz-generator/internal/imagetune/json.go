package imagetune

import (
	"fmt"
	"strings"
)

// extractJSON pulls the first balanced JSON object out of an LLM reply. Models
// frequently wrap JSON in ```json fences or prepend chain-of-thought prose, so
// we scan for the first '{' and return through its matching '}', ignoring braces
// inside strings.
func extractJSON(s string) (string, error) {
	start := strings.IndexByte(s, '{')
	if start < 0 {
		return "", fmt.Errorf("no JSON object found in response")
	}
	depth := 0
	inStr := false
	escaped := false
	for i := start; i < len(s); i++ {
		ch := s[i]
		if inStr {
			switch {
			case escaped:
				escaped = false
			case ch == '\\':
				escaped = true
			case ch == '"':
				inStr = false
			}
			continue
		}
		switch ch {
		case '"':
			inStr = true
		case '{':
			depth++
		case '}':
			depth--
			if depth == 0 {
				return s[start : i+1], nil
			}
		}
	}
	return "", fmt.Errorf("unbalanced JSON object in response")
}
