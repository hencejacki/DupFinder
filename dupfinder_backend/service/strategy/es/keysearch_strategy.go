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

// 关键查询: 命中文字高亮且为摘要返回

type KeySearchStrategy struct{}

func (k *KeySearchStrategy) GoSearch(req request.SearchRequest, lang string) (int, []model.Document, error) {
	// 构造查询条件
	if reader, err := k.queryBuild(req); err != nil {
		log.Fatalf("Error build query statement: %s\n", err)
		return 0, nil, errors.New("搜索失败")
	} else {
		return utils.KeySearchDocument(reader, lang)
	}
}

// 查询语句构建
func (k *KeySearchStrategy) queryBuild(req request.SearchRequest) (io.Reader, error) {
	var buf bytes.Buffer
	query := map[string]interface{}{
		"query": map[string]interface{}{
			"match": map[string]interface{}{
				"content": req.Keyword,
			},
		},
		"from": req.From,
		"size": req.Size,
		"highlight": map[string]interface{}{
			"fields": map[string]interface{}{
				"content": map[string]interface{}{},
			},
			"pre_tags":  "<b>",
			"post_tags": "</b>",
		},
	}
	err := json.NewEncoder(&buf).Encode(query)
	if err != nil {
		log.Fatalf("Error encoding query: %s", err)
	}
	return &buf, err
}
