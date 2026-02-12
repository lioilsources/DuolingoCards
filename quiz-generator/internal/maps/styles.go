package maps

import "image/color"

// Feature styles for different geography categories.
var (
	// MountainStyle uses earthy brown/orange tones.
	MountainStyle = RenderOptions{
		MaxWidth:       800,
		MaxHeight:      600,
		Padding:        0.5,
		HighlightColor: color.RGBA{R: 139, G: 69, B: 19, A: 255}, // Saddle brown
		LineWidth:      4,
	}

	// RiverStyle uses blue tones.
	RiverStyle = RenderOptions{
		MaxWidth:       800,
		MaxHeight:      600,
		Padding:        1.0,
		HighlightColor: color.RGBA{R: 30, G: 144, B: 255, A: 255}, // Dodger blue
		LineWidth:      3,
	}

	// BorderStyle uses darker gray/black.
	BorderStyle = RenderOptions{
		MaxWidth:       800,
		MaxHeight:      600,
		Padding:        0.5,
		HighlightColor: color.RGBA{R: 50, G: 50, B: 50, A: 255}, // Dark gray
		LineWidth:      2,
	}
)

// StyleForCategory returns the appropriate render style for a geography category.
func StyleForCategory(category string) RenderOptions {
	switch category {
	case "mountains":
		return MountainStyle
	case "rivers":
		return RiverStyle
	case "borders":
		return BorderStyle
	default:
		return DefaultRenderOptions()
	}
}
