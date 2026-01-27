package capitals

import "fmt"

// BuildQuery returns a SPARQL query for world capitals with population data.
func BuildQuery(lang string, limit int) string {
	return fmt.Sprintf(`
SELECT DISTINCT ?country ?countryLabel ?capital ?capitalLabel
       ?flag ?countryPopulation ?capitalPopulation ?countryCode
WHERE {
  # Instance of sovereign state
  ?country wdt:P31 wd:Q3624078 .

  # Has capital city
  ?country wdt:P36 ?capital .

  # Has flag image
  ?country wdt:P41 ?flag .

  # Country population (required)
  ?country wdt:P1082 ?countryPopulation .

  # ISO 3166-1 alpha-2 code
  ?country wdt:P297 ?countryCode .

  # Capital population (optional)
  OPTIONAL { ?capital wdt:P1082 ?capitalPopulation . }

  # Get labels in specified language, fallback to English
  SERVICE wikibase:label { bd:serviceParam wikibase:language "%s,en" . }
}
ORDER BY DESC(?countryPopulation)
LIMIT %d
`, lang, limit)
}

// BuildQueryWithWikidataID returns a query that also extracts the Wikidata ID.
func BuildQueryWithWikidataID(lang string, limit int) string {
	return fmt.Sprintf(`
SELECT DISTINCT ?country ?countryLabel ?capital ?capitalLabel
       ?flag ?countryPopulation ?capitalPopulation ?countryCode
WHERE {
  # Instance of sovereign state
  ?country wdt:P31 wd:Q3624078 .

  # Has capital city
  ?country wdt:P36 ?capital .

  # Has flag image
  ?country wdt:P41 ?flag .

  # Country population (required)
  ?country wdt:P1082 ?countryPopulation .

  # ISO 3166-1 alpha-2 code
  ?country wdt:P297 ?countryCode .

  # Capital population (optional)
  OPTIONAL { ?capital wdt:P1082 ?capitalPopulation . }

  # Get labels in specified language, fallback to English
  SERVICE wikibase:label { bd:serviceParam wikibase:language "%s,en" . }
}
ORDER BY DESC(?countryPopulation)
LIMIT %d
`, lang, limit)
}
