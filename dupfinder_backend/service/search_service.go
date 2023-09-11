package service

import (
	"dupbackend/global"
	"dupbackend/model/request"
	"dupbackend/model/response"
	"dupbackend/service/strategy"
	"errors"
	"log"
)

// 搜索服务层
type SearchService struct{}

const (
	maxSize = 30 // 页请求最大数量
	minSize = 10 // 页请求最小数量
)

// 搜索文档
func (s *SearchService) SearchDoc(req request.SearchRequest) (*response.SearchResponse, error) {
	// 1. 参数校验
	if req.Keyword == "" {
		return nil, errors.New("参数错误: 关键字不能为空")
	}
	if req.From < 0 || req.Size < 0 {
		return nil, errors.New("参数错误: 请求页数错误")
	}
	if req.Size < minSize || req.Size > maxSize {
		return nil, errors.New("参数错误: 请求页数大小错误")
	}
	if _, exists := global.GVA_ES_CONFIG.LangIndexs[req.Lang]; !exists {
		return nil, errors.New("参数错误: 请求索引错误")
	}
	if _, exists := global.GVA_ES_CONFIG.SearchType[req.Type]; !exists {
		return nil, errors.New("参数错误: 请求检索类型错误")
	}

	// 3.1 搜索上下文初始化
	var searchContext strategy.SearchContext
	exec := searchContext.InitSearchContext(req.Type)

	total, docs, err := exec.GoSearch(req, req.Lang)

	if err != nil {
		log.Fatalf("Error Search document: %s\n", err)
		return nil, errors.New("搜索失败")
	}
	ret := &response.SearchResponse{
		Total:   total,
		Current: req.From,
		Size:    req.Size,
		Records: docs,
	}
	return ret, err
}
