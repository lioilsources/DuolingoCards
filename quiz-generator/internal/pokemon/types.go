package pokemon

// PokemonData holds combined data from both /pokemon and /pokemon-species endpoints.
type PokemonData struct {
	ID         int
	Name       string   // English name
	NameJA     string   // Japanese name (katakana)
	Types      []string // e.g., ["electric"], ["fire", "flying"]
	Stats      Stats
	Height     int // decimetres
	Weight     int // hectograms
	Generation string
	ArtworkURL string
}

// Stats holds the six base stats.
type Stats struct {
	HP      int
	Attack  int
	Defense int
	SpAtk   int
	SpDef   int
	Speed   int
}

// CzechTypeNames maps English type names to Czech.
var CzechTypeNames = map[string]string{
	"normal":   "Normální",
	"fire":     "Ohnivý",
	"water":    "Vodní",
	"electric": "Elektrický",
	"grass":    "Travní",
	"ice":      "Ledový",
	"fighting": "Bojový",
	"poison":   "Jedový",
	"ground":   "Zemní",
	"flying":   "Létající",
	"psychic":  "Psychický",
	"bug":      "Hmyzí",
	"rock":     "Kamenný",
	"ghost":    "Přízračný",
	"dragon":   "Dračí",
	"dark":     "Temný",
	"steel":    "Ocelový",
	"fairy":    "Pohádkový",
}

// GenerationMap converts API generation strings to Roman numerals.
var GenerationMap = map[string]string{
	"generation-i":    "I",
	"generation-ii":   "II",
	"generation-iii":  "III",
	"generation-iv":   "IV",
	"generation-v":    "V",
	"generation-vi":   "VI",
	"generation-vii":  "VII",
	"generation-viii": "VIII",
	"generation-ix":   "IX",
}
