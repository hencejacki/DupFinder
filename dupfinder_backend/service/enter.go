package service

type serviceGroups struct {
	SearchService
	DuplicateCheckService
	ClusterResultService
	GPTService
}

var Services = new(serviceGroups)
