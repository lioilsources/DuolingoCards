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

// Targets is the canonical language list for the content pipeline.
var Targets = []Target{
	// Original top-20
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
	// Classical / constructed
	{Code: "la", Name: "Latin"},
	{Code: "sa", Name: "Sanskrit"},
	{Code: "eo", Name: "Esperanto"},
	// Middle East & South Caucasus
	{Code: "el", Name: "Greek"},
	{Code: "he", Name: "Hebrew", RTL: true},
	{Code: "fa", Name: "Persian", RTL: true},
	{Code: "yi", Name: "Yiddish", RTL: true},
	{Code: "az", Name: "Azerbaijani"},
	{Code: "hy", Name: "Armenian"},
	{Code: "ka", Name: "Georgian"},
	// East Europe & Balkans
	{Code: "pl", Name: "Polish"},
	{Code: "sk", Name: "Slovak"},
	{Code: "hu", Name: "Hungarian"},
	{Code: "ro", Name: "Romanian"},
	{Code: "bg", Name: "Bulgarian"},
	{Code: "uk", Name: "Ukrainian"},
	{Code: "be", Name: "Belarusian"},
	{Code: "sr", Name: "Serbian"},
	{Code: "hr", Name: "Croatian"},
	{Code: "sl", Name: "Slovenian"},
	{Code: "bs", Name: "Bosnian"},
	{Code: "mk", Name: "Macedonian"},
	{Code: "sq", Name: "Albanian"},
	// West & North Europe
	{Code: "nl", Name: "Dutch"},
	{Code: "nl-BE", Name: "Flemish"},
	{Code: "da", Name: "Danish"},
	{Code: "nb", Name: "Norwegian (Bokmål)"},
	{Code: "sv", Name: "Swedish"},
	{Code: "fi", Name: "Finnish"},
	{Code: "is", Name: "Icelandic"},
	{Code: "mt", Name: "Maltese"},
	// Baltic
	{Code: "lt", Name: "Lithuanian"},
	{Code: "lv", Name: "Latvian"},
	{Code: "et", Name: "Estonian"},
	// Celtic
	{Code: "ga", Name: "Irish"},
	{Code: "cy", Name: "Welsh"},
	// Southern Europe
	{Code: "it", Name: "Italian"},
	// Horn of Africa
	{Code: "am", Name: "Amharic"},
	// South Asia
	{Code: "ne", Name: "Nepali"},
	// Central & Inner Asia
	{Code: "uz", Name: "Uzbek"},
	{Code: "tk", Name: "Turkmen"},
	{Code: "mn", Name: "Mongolian"},
	// Southeast Asia
	{Code: "th", Name: "Thai"},
	{Code: "my", Name: "Burmese"},
	{Code: "km", Name: "Khmer"},
	{Code: "lo", Name: "Lao"},
	{Code: "ms", Name: "Malay"},
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
