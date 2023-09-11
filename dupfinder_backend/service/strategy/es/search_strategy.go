package es

import (
	"dupbackend/model"
	"dupbackend/model/request"
)

type SearchStrategy interface {
	GoSearch(request.SearchRequest, string) (int, []model.Document, error)
}
