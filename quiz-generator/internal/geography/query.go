package geography

import (
	"fmt"

	"github.com/duolingocards/quiz-generator/internal/overpass"
)

// QueryMountainRanges builds an Overpass query for mountain ranges.
// Returns relations tagged as mountain_range with bounds.
func QueryMountainRanges(limit int) string {
	return fmt.Sprintf(`[out:json][timeout:90];
(
  relation["natural"="mountain_range"]["name"]["wikidata"];
);
out body bb %d;`, limit*2) // Fetch more to account for filtering
}

// QueryMountainRangeByName queries a specific mountain range by name.
func QueryMountainRangeByName(name string) string {
	return fmt.Sprintf(`[out:json][timeout:60];
relation["natural"="mountain_range"]["name"="%s"];
out body bb;
>;
out skel qt;`, name)
}

// QueryMountainRangeByWikidata queries a mountain range by Wikidata ID.
func QueryMountainRangeByWikidata(wikidataID string) string {
	return fmt.Sprintf(`[out:json][timeout:60];
relation["natural"="mountain_range"]["wikidata"="%s"];
out body bb;`, wikidataID)
}

// QueryRivers builds an Overpass query for major rivers.
func QueryRivers(limit int) string {
	return fmt.Sprintf(`[out:json][timeout:90];
(
  relation["waterway"="river"]["name"]["wikidata"]["wikipedia"];
);
out body bb %d;`, limit*2)
}

// QueryRiverByName queries a specific river by name.
// Searches both 'name' and 'name:en' tags for better matching.
// Uses 'out geom' to get geometry inline with the relation.
func QueryRiverByName(name string) string {
	return fmt.Sprintf(`[out:json][timeout:90];
(
  relation["waterway"="river"]["name"="%s"];
  relation["waterway"="river"]["name:en"="%s"];
  relation["waterway"="river"]["name:en"~"%s",i];
);
out geom;`, name, name, name)
}

// ParseMountainRanges extracts mountain range features from Overpass results.
func ParseMountainRanges(result *overpass.QueryResult) []Feature {
	var features []Feature

	for _, elem := range result.Elements {
		if elem.Type != "relation" {
			continue
		}

		name := overpass.GetTag(elem, "name")
		if name == "" {
			continue
		}

		bounds := overpass.GetBounds(elem)
		if bounds == nil {
			continue
		}

		// Skip if bounds are too small (likely incomplete data)
		if bounds.MaxLat-bounds.MinLat < 0.5 || bounds.MaxLon-bounds.MinLon < 0.5 {
			continue
		}

		feature := Feature{
			ID:         fmt.Sprintf("mountain-%d", elem.ID),
			Name:       name,
			NameLocal:  overpass.GetTag(elem, "name:en"),
			Type:       "mountain_range",
			Category:   "mountains",
			Wikipedia:  overpass.GetTag(elem, "wikipedia"),
			WikidataID: overpass.GetTag(elem, "wikidata"),
			Bounds:     bounds,
		}

		// Try to get alternate names
		if feature.NameLocal == "" {
			feature.NameLocal = name
		}

		features = append(features, feature)
	}

	return features
}

// ParseRivers extracts river features from Overpass results.
func ParseRivers(result *overpass.QueryResult) []Feature {
	var features []Feature

	for _, elem := range result.Elements {
		if elem.Type != "relation" {
			continue
		}

		name := overpass.GetTag(elem, "name")
		if name == "" {
			continue
		}

		bounds := overpass.GetBounds(elem)
		if bounds == nil {
			continue
		}

		feature := Feature{
			ID:         fmt.Sprintf("river-%d", elem.ID),
			Name:       name,
			NameLocal:  overpass.GetTag(elem, "name:en"),
			Type:       "river",
			Category:   "rivers",
			Wikipedia:  overpass.GetTag(elem, "wikipedia"),
			WikidataID: overpass.GetTag(elem, "wikidata"),
			Bounds:     bounds,
		}

		if feature.NameLocal == "" {
			feature.NameLocal = name
		}

		// Extract geometry for line rendering
		for _, member := range elem.Members {
			if len(member.Geometry) > 0 {
				feature.Geometry = append(feature.Geometry, member.Geometry...)
			}
		}

		features = append(features, feature)
	}

	return features
}

// MountainRangeNames returns a list of well-known mountain ranges to query.
// Using curated list ensures high-quality, complete data.
var MountainRangeNames = []string{
	"Alps",
	"Himalayas",
	"Andes",
	"Rocky Mountains",
	"Pyrenees",
	"Carpathian Mountains",
	"Caucasus Mountains",
	"Ural Mountains",
	"Atlas Mountains",
	"Appalachian Mountains",
	"Scandinavian Mountains",
	"Dinaric Alps",
	"Sierra Nevada",
	"Tian Shan",
	"Kunlun Mountains",
	"Karakoram",
	"Hindu Kush",
	"Drakensberg",
	"Great Dividing Range",
	"Southern Alps",
}

// RiverNames returns a list of well-known rivers to query.
var RiverNames = []string{
	"Amazon",
	"Nile",
	"Danube",
	"Rhine",
	"Volga",
	"Mississippi",
	"Yangtze",
	"Ganges",
	"Mekong",
	"Congo",
}
