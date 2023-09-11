package es

import (
	"bytes"
	"dupbackend/model"
	"dupbackend/model/request"
	"dupbackend/utils"
	"encoding/json"
	"errors"
	"io"
	"log"
)

// 全量查询: 命中全文返回

type FullSearchStrategy struct{}

func (f *FullSearchStrategy) GoSearch(req request.SearchRequest, lang string) (int, []model.Document, error) {
	// 构造查询条件
	if reader, err := f.queryBuild(req); err != nil {
		log.Fatalf("Error build query statement: %s\n", err)
		return 0, nil, errors.New("搜索失败")
	} else {
		return utils.KeySearchDocument(reader, lang)
	}
}

// 查询语句构建
func (f *FullSearchStrategy) queryBuild(req request.SearchRequest) (io.Reader, error) {
	var buf bytes.Buffer
	query := map[string]interface{}{
		"query": map[string]interface{}{
			"match": map[string]interface{}{
				"content": req.Keyword,
			},
		},
		"from": req.From,
		"size": req.Size,
	}
	err := json.NewEncoder(&buf).Encode(query)
	if err != nil {
		log.Fatalf("Error encoding query: %s", err)
	}
	return &buf, err
}
