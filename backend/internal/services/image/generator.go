package image

// Generator is the backend-neutral interface for image generation.
type Generator interface {
	GenerateImage(prompt string) ([]byte, error)
}
