package api

import "dupbackend/service"

type handlerFunc struct {
	HomeApi
	DupCheckApi
	ClusterResApi
	QuestionAnswerApi
}

var (
	searchService  = service.Services.SearchService
	compareService = service.Services.DuplicateCheckService
	clusterService = service.Services.ClusterResultService
	gptService     = service.Services.GPTService
)

var Handler = new(handlerFunc)
