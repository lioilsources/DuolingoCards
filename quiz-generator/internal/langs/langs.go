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
	Gold bool   // gold-quality (hand-authored/verified); shipped as a supported language
}

// Targets is the canonical language list for the content pipeline.
// Gold: true marks a language whose translations are hand-authored/verified for
// the real decks and therefore shipped as a supported language (see build gating
// in internal/content). Languages without Gold remain valid translation targets
// (tracked, lintable, translatable) but are not shipped until promoted.
var Targets = []Target{
	// Original top-20 (en is the pivot — see Pivot below — so it is not a target)
	{Code: "zh-CN", Name: "Chinese (Simplified)", Gold: true},
	{Code: "hi", Name: "Hindi", Gold: true},
	{Code: "es-419", Name: "Spanish (Latin America)", Gold: true},
	{Code: "ar", Name: "Arabic", RTL: true, Gold: true},
	{Code: "fr", Name: "French", Gold: true},
	{Code: "bn", Name: "Bengali"},
	{Code: "pt-BR", Name: "Portuguese (Brazil)", Gold: true},
	{Code: "ru", Name: "Russian", Gold: true},
	{Code: "id", Name: "Indonesian", Gold: true},
	{Code: "ur", Name: "Urdu", RTL: true},
	{Code: "de", Name: "German", Gold: true},
	{Code: "ja", Name: "Japanese", Gold: true},
	{Code: "mr", Name: "Marathi"},
	{Code: "te", Name: "Telugu"},
	{Code: "tr", Name: "Turkish", Gold: true},
	{Code: "ta", Name: "Tamil"},
	{Code: "vi", Name: "Vietnamese", Gold: true},
	{Code: "ko", Name: "Korean", Gold: true},
	{Code: "ha", Name: "Hausa"},
	// Classical / constructed
	{Code: "la", Name: "Latin"},
	{Code: "sa", Name: "Sanskrit"},
	{Code: "eo", Name: "Esperanto"},
	// Middle East & South Caucasus
	{Code: "el", Name: "Greek", Gold: true},
	{Code: "he", Name: "Hebrew", RTL: true, Gold: true},
	{Code: "fa", Name: "Persian", RTL: true},
	{Code: "yi", Name: "Yiddish", RTL: true},
	{Code: "az", Name: "Azerbaijani"},
	{Code: "hy", Name: "Armenian"},
	{Code: "ka", Name: "Georgian"},
	// East Europe & Balkans
	{Code: "cs", Name: "Czech", Gold: true}, // former pivot, now a translation target
	{Code: "pl", Name: "Polish", Gold: true},
	{Code: "sk", Name: "Slovak", Gold: true},
	{Code: "hu", Name: "Hungarian"},
	{Code: "ro", Name: "Romanian", Gold: true},
	{Code: "bg", Name: "Bulgarian", Gold: true},
	{Code: "uk", Name: "Ukrainian", Gold: true},
	{Code: "be", Name: "Belarusian"},
	{Code: "sr", Name: "Serbian", Gold: true},
	{Code: "hr", Name: "Croatian", Gold: true},
	{Code: "sl", Name: "Slovenian", Gold: true},
	{Code: "bs", Name: "Bosnian"},
	{Code: "mk", Name: "Macedonian"},
	{Code: "sq", Name: "Albanian"},
	// West & North Europe
	{Code: "nl", Name: "Dutch", Gold: true},
	{Code: "nl-BE", Name: "Flemish"},
	{Code: "da", Name: "Danish", Gold: true},
	{Code: "nb", Name: "Norwegian (Bokmål)", Gold: true},
	{Code: "sv", Name: "Swedish", Gold: true},
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
	{Code: "it", Name: "Italian", Gold: true},
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

// SupportedSet returns the set of language codes shipped to the app as
// "supported": the pivot plus every Gold-flagged target. Long-tail (non-gold)
// targets stay in Targets — tracked and translatable — but are excluded here so
// the build does not ship or surface them until they are promoted to Gold.
func SupportedSet() map[string]bool {
	out := map[string]bool{Pivot: true}
	for _, t := range Targets {
		if t.Gold {
			out[t.Code] = true
		}
	}
	return out
}

// IsSupported reports whether a language code is shipped as a supported
// language (the pivot or a Gold-flagged target).
func IsSupported(code string) bool {
	if code == Pivot {
		return true
	}
	for _, t := range Targets {
		if t.Code == code {
			return t.Gold
		}
	}
	return false
}

// Pivot is the language in which content is authored and fact-checked before
// translation, and the source from which every target is translated. English is
// the pivot because en→X translation is far better resourced in models than
// cs→X, which reduces wrong-word / transliterate-the-source errors. It is
// intentionally excluded from Targets so lint does not require it as a target.
const Pivot = "en"

// displayNames gives the English display name for codes not in Targets (the
// pivot). Targets carry their own Name.
var displayNames = map[string]string{"en": "English"}

// Name returns the English display name for a language code (target or pivot),
// falling back to the code itself.
func Name(code string) string {
	for _, t := range Targets {
		if t.Code == code {
			return t.Name
		}
	}
	if n, ok := displayNames[code]; ok {
		return n
	}
	return code
}

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
