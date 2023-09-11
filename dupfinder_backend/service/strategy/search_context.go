package strategy

import (
	"dupbackend/model"
	"dupbackend/model/request"
	"dupbackend/service/strategy/es"
)

type SearchContext struct {
	strategy es.SearchStrategy
}

const (
	fullSearch = "full"
	keySearch  = "key"
)

func (sc *SearchContext) InitSearchContext(searchType string) *SearchContext {
	var searchContext SearchContext
	switch searchType {
	case fullSearch:
		searchContext.strategy = new(es.FullSearchStrategy)
		break
	case keySearch:
		searchContext.strategy = new(es.KeySearchStrategy)
		break
	default:
		break
	}
	return &searchContext
}

func (sc *SearchContext) GoSearch(req request.SearchRequest, lang string) (int, []model.Document, error) {
	return sc.strategy.GoSearch(req, lang)
}
