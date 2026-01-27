package catbreeds

import "fmt"

// BuildQuery returns a SPARQL query for cat breeds with images and origin.
func BuildQuery(lang string, limit int) string {
	return fmt.Sprintf(`
SELECT DISTINCT ?breed ?breedLabel ?breedLabelEn ?image ?origin ?originLabel
WHERE {
  # Instance of cat breed
  ?breed wdt:P31 wd:Q43577 .

  # Has image (required)
  ?breed wdt:P18 ?image .

  # Country of origin (optional)
  OPTIONAL { ?breed wdt:P495 ?origin . }

  # Get English label for subtitle
  OPTIONAL { ?breed rdfs:label ?breedLabelEn . FILTER(LANG(?breedLabelEn) = "en") }

  # Get labels in specified language, fallback to English
  SERVICE wikibase:label { bd:serviceParam wikibase:language "%s,en" . }
}
LIMIT %d
`, lang, limit)
}
