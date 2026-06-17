// Package langs defines the target localization languages for DuolingoCards
// and small helpers (RTL detection, BCP-47 → TTS hints) shared by the
// build-time content tooling.
//
// The list and locale codes follow the v1/v2 plan (top 20 languages). Any
// concept's label/summary/info must be authored in all of these for a deck to
// pass `lint`.
package langs

// Target is one localization language.
type Target struct {
	Code string // BCP-47 locale code used as the i18n file name and JSON key
	Name string // English display name (for tooling output)
	RTL  bool   // right-to-left script
}

// Targets is the canonical top-20 language list from the plan.
var Targets = []Target{
	{Code: "en", Name: "English"},
	{Code: "zh-CN", Name: "Chinese (Simplified)"},
	{Code: "hi", Name: "Hindi"},
	{Code: "es-419", Name: "Spanish (Latin America)"},
	{Code: "ar", Name: "Arabic", RTL: true},
	{Code: "fr", Name: "French"},
	{Code: "bn", Name: "Bengali"},
	{Code: "pt-BR", Name: "Portuguese (Brazil)"},
	{Code: "ru", Name: "Russian"},
	{Code: "id", Name: "Indonesian"},
	{Code: "ur", Name: "Urdu", RTL: true},
	{Code: "de", Name: "German"},
	{Code: "ja", Name: "Japanese"},
	{Code: "mr", Name: "Marathi"},
	{Code: "te", Name: "Telugu"},
	{Code: "tr", Name: "Turkish"},
	{Code: "ta", Name: "Tamil"},
	{Code: "vi", Name: "Vietnamese"},
	{Code: "ko", Name: "Korean"},
	{Code: "ha", Name: "Hausa"},
	{Code: "la", Name: "Latin"},
{Code: "eo", Name: "Esperanto"},
	{Code: "el", Name: "Greek"},
	{Code: "he", Name: "Hebrew", RTL: true},
	{Code: "fa", Name: "Persian", RTL: true},
	{Code: "ga", Name: "Irish"},
	{Code: "cy", Name: "Welsh"},
	{Code: "yi", Name: "Yiddish", RTL: true},
}

// Codes returns just the locale codes, in canonical order.
func Codes() []string {
	out := make([]string, len(Targets))
	for i, t := range Targets {
		out[i] = t.Code
	}
	return out
}

// Set returns the target codes as a lookup set.
func Set() map[string]bool {
	out := make(map[string]bool, len(Targets))
	for _, t := range Targets {
		out[t.Code] = true
	}
	return out
}

// IsTarget reports whether code is one of the canonical target languages.
func IsTarget(code string) bool {
	for _, t := range Targets {
		if t.Code == code {
			return true
		}
	}
	return false
}

// Pivot is the language in which content is authored and fact-checked before
// translation. It is intentionally excluded from Targets so lint does not
// require it as a translation target.
const Pivot = "cs"

// IsPivot reports whether code is the pivot (authoring) language.
func IsPivot(code string) bool { return code == Pivot }

// IsRTL reports whether the given target code uses a right-to-left script.
func IsRTL(code string) bool {
	for _, t := range Targets {
		if t.Code == code {
			return t.RTL
		}
	}
	return false
}
