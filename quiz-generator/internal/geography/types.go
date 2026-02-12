package geography

import "github.com/duolingocards/quiz-generator/internal/overpass"

// Feature represents a geographic feature with metadata for quiz generation.
type Feature struct {
	ID          string
	Name        string
	NameLocal   string // Name in local language
	Type        string // "mountain_range", "river", "border"
	Category    string // "mountains", "rivers", "borders"
	Wikipedia   string
	WikidataID  string
	Bounds      *overpass.Bounds
	Geometry    []overpass.LatLon
	Length      string // For rivers, mountain ranges
	Elevation   string // Highest point for mountains
	Countries   []string
	Description string
}

// Mountain represents a mountain range feature.
type Mountain struct {
	Feature
	HighestPeak     string
	HighestPeakElev string
}

// River represents a river feature.
type River struct {
	Feature
	Source    string
	Mouth     string
	LengthKm  float64
	DrainArea string
}

// MountainRangeData contains curated data for major mountain ranges.
// This supplements Overpass data which may be incomplete.
var MountainRangeData = map[string]struct {
	NameCS       string
	HighestPeak  string
	PeakElevM    string
	LengthKm     string
	Countries    string
}{
	"Alps": {
		NameCS:      "Alpy",
		HighestPeak: "Mont Blanc",
		PeakElevM:   "4 808 m",
		LengthKm:    "1 200 km",
		Countries:   "Francie, Itálie, Švýcarsko, Rakousko, Německo, Slovinsko, Lichtenštejnsko, Monako",
	},
	"Himalayas": {
		NameCS:      "Himálaj",
		HighestPeak: "Mount Everest",
		PeakElevM:   "8 849 m",
		LengthKm:    "2 400 km",
		Countries:   "Nepál, Čína, Indie, Bhútán, Pákistán",
	},
	"Andes": {
		NameCS:      "Andy",
		HighestPeak: "Aconcagua",
		PeakElevM:   "6 961 m",
		LengthKm:    "7 000 km",
		Countries:   "Argentina, Chile, Peru, Bolívie, Ekvádor, Kolumbie, Venezuela",
	},
	"Rocky Mountains": {
		NameCS:      "Skalnaté hory",
		HighestPeak: "Mount Elbert",
		PeakElevM:   "4 401 m",
		LengthKm:    "4 800 km",
		Countries:   "Kanada, USA",
	},
	"Pyrenees": {
		NameCS:      "Pyreneje",
		HighestPeak: "Pico de Aneto",
		PeakElevM:   "3 404 m",
		LengthKm:    "430 km",
		Countries:   "Francie, Španělsko, Andorra",
	},
	"Carpathian Mountains": {
		NameCS:      "Karpaty",
		HighestPeak: "Gerlachovský štít",
		PeakElevM:   "2 655 m",
		LengthKm:    "1 500 km",
		Countries:   "Slovensko, Polsko, Ukrajina, Rumunsko, Česko, Maďarsko, Srbsko",
	},
	"Caucasus Mountains": {
		NameCS:      "Kavkaz",
		HighestPeak: "Elbrus",
		PeakElevM:   "5 642 m",
		LengthKm:    "1 100 km",
		Countries:   "Rusko, Gruzie, Ázerbájdžán, Arménie",
	},
	"Ural Mountains": {
		NameCS:      "Ural",
		HighestPeak: "Mount Narodnaya",
		PeakElevM:   "1 895 m",
		LengthKm:    "2 500 km",
		Countries:   "Rusko, Kazachstán",
	},
	"Atlas Mountains": {
		NameCS:      "Atlas",
		HighestPeak: "Toubkal",
		PeakElevM:   "4 167 m",
		LengthKm:    "2 500 km",
		Countries:   "Maroko, Alžírsko, Tunisko",
	},
	"Appalachian Mountains": {
		NameCS:      "Apalačské pohoří",
		HighestPeak: "Mount Mitchell",
		PeakElevM:   "2 037 m",
		LengthKm:    "2 400 km",
		Countries:   "USA, Kanada",
	},
	"Scandinavian Mountains": {
		NameCS:      "Skandinávské pohoří",
		HighestPeak: "Galdhøpiggen",
		PeakElevM:   "2 469 m",
		LengthKm:    "1 700 km",
		Countries:   "Norsko, Švédsko, Finsko",
	},
	"Dinaric Alps": {
		NameCS:      "Dinárské hory",
		HighestPeak: "Maja Jezercë",
		PeakElevM:   "2 694 m",
		LengthKm:    "645 km",
		Countries:   "Slovinsko, Chorvatsko, Bosna a Hercegovina, Černá Hora, Albánie, Kosovo, Srbsko",
	},
	"Sierra Nevada": {
		NameCS:      "Sierra Nevada (USA)",
		HighestPeak: "Mount Whitney",
		PeakElevM:   "4 421 m",
		LengthKm:    "640 km",
		Countries:   "USA",
	},
	"Tian Shan": {
		NameCS:      "Ťan-šan",
		HighestPeak: "Jengish Chokusu",
		PeakElevM:   "7 439 m",
		LengthKm:    "2 800 km",
		Countries:   "Kyrgyzstán, Kazachstán, Čína, Uzbekistán",
	},
	"Kunlun Mountains": {
		NameCS:      "Kunlun",
		HighestPeak: "Liushi Shan",
		PeakElevM:   "7 167 m",
		LengthKm:    "3 000 km",
		Countries:   "Čína",
	},
	"Karakoram": {
		NameCS:      "Karákoram",
		HighestPeak: "K2",
		PeakElevM:   "8 611 m",
		LengthKm:    "500 km",
		Countries:   "Pákistán, Čína, Indie",
	},
	"Hindu Kush": {
		NameCS:      "Hindúkuš",
		HighestPeak: "Tirich Mir",
		PeakElevM:   "7 708 m",
		LengthKm:    "800 km",
		Countries:   "Afghánistán, Pákistán",
	},
	"Drakensberg": {
		NameCS:      "Dračí hory",
		HighestPeak: "Thabana Ntlenyana",
		PeakElevM:   "3 482 m",
		LengthKm:    "1 000 km",
		Countries:   "Jihoafrická republika, Lesotho, Eswatini",
	},
	"Great Dividing Range": {
		NameCS:      "Velké předělové pohoří",
		HighestPeak: "Mount Kosciuszko",
		PeakElevM:   "2 228 m",
		LengthKm:    "3 500 km",
		Countries:   "Austrálie",
	},
	"Southern Alps": {
		NameCS:      "Jižní Alpy",
		HighestPeak: "Aoraki/Mount Cook",
		PeakElevM:   "3 724 m",
		LengthKm:    "500 km",
		Countries:   "Nový Zéland",
	},
}

// RiverData contains curated data for major rivers.
var RiverData = map[string]struct {
	NameCS   string
	LengthKm string
	Source   string
	Mouth    string
}{
	"Amazon": {
		NameCS:   "Amazonka",
		LengthKm: "6 992 km",
		Source:   "Nevado Mismi, Peru",
		Mouth:    "Atlantský oceán",
	},
	"Nile": {
		NameCS:   "Nil",
		LengthKm: "6 650 km",
		Source:   "Jezero Viktorie",
		Mouth:    "Středozemní moře",
	},
	"Danube": {
		NameCS:   "Dunaj",
		LengthKm: "2 850 km",
		Source:   "Schwarzwald, Německo",
		Mouth:    "Černé moře",
	},
	"Rhine": {
		NameCS:   "Rýn",
		LengthKm: "1 233 km",
		Source:   "Švýcarské Alpy",
		Mouth:    "Severní moře",
	},
	"Volga": {
		NameCS:   "Volha",
		LengthKm: "3 531 km",
		Source:   "Valdajská vysočina",
		Mouth:    "Kaspické moře",
	},
	"Mississippi": {
		NameCS:   "Mississippi",
		LengthKm: "3 730 km",
		Source:   "Jezero Itasca, Minnesota",
		Mouth:    "Mexický záliv",
	},
	"Yangtze": {
		NameCS:   "Jang-c'-ťiang",
		LengthKm: "6 300 km",
		Source:   "Tibetská náhorní plošina",
		Mouth:    "Východočínské moře",
	},
	"Ganges": {
		NameCS:   "Ganga",
		LengthKm: "2 525 km",
		Source:   "Gangotri, Himálaj",
		Mouth:    "Bengálský záliv",
	},
	"Mekong": {
		NameCS:   "Mekong",
		LengthKm: "4 350 km",
		Source:   "Tibetská náhorní plošina",
		Mouth:    "Jihočínské moře",
	},
	"Congo": {
		NameCS:   "Kongo",
		LengthKm: "4 700 km",
		Source:   "Zambie",
		Mouth:    "Atlantský oceán",
	},
}
