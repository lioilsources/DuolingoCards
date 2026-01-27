package generator

// QuizItem represents a generic quiz item from any data source.
type QuizItem struct {
	ID         string
	Title      string
	Subtitle   string
	ImageURL   string
	LocalImage string
	Fields     []Field
	WikidataID string
}

// Field represents a label-value pair for dynamic quiz data.
type Field struct {
	Label string `json:"label"`
	Value string `json:"value"`
}

// Options contains configuration for quiz generation.
type Options struct {
	Limit    int
	Language string
	Country  string
	Region   string
}

// QuizGenerator defines the interface for quiz data generators.
type QuizGenerator interface {
	Name() string
	FetchData(opts Options) ([]QuizItem, error)
	DownloadMedia(items []QuizItem, outputDir string) ([]QuizItem, error)
}
