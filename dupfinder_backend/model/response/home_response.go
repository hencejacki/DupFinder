package response

import "dupbackend/model"

type SearchResponse struct {
	Total   int              `json:"total"`
	Current int              `json:"current"`
	Size    int              `json:"size"`
	Records []model.Document `json:"records"`
}
