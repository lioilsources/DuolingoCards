package models

type Media struct {
	Image      string `json:"image,omitempty"`
	AudioFront string `json:"audioFront,omitempty"`
	AudioBack  string `json:"audioBack,omitempty"`
	Video      string `json:"video,omitempty"`
}

type Card struct {
	ID          string  `json:"id"`
	FrontText   string  `json:"frontText"`
	BackText    string  `json:"backText"`
	Reading     string  `json:"reading,omitempty"`
	Priority    int     `json:"priority"`
	Media       *Media  `json:"media,omitempty"`
	MediaStatus string  `json:"mediaStatus,omitempty"` // pending, generating, ready, error
}

type CardInput struct {
	ID        string `json:"id"`
	FrontText string `json:"frontText"`
	BackText  string `json:"backText"`
	Reading   string `json:"reading,omitempty"`
}
