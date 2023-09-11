package utils

import (
	"context"
	"dupbackend/global"
	"dupbackend/model"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math/rand"
	"strconv"
	"strings"
	"time"

	"github.com/elastic/go-elasticsearch/v8"
	"github.com/elastic/go-elasticsearch/v8/esapi"
)

// 根据具体i情况获取ES客户端
func getEsCLient() (*elasticsearch.Client, error) {
	if global.GVA_ES == nil {
		return elasticsearch.NewDefaultClient()
	}
	return global.GVA_ES, nil
}

// 创建索引
func CreateIndex(indexName string, doc model.Document) *esapi.Response {
	es, _ := getEsCLient()

	ctx := context.Background()

	req := esapi.IndexRequest{
		Index:      "test",                             // Index name
		Body:       strings.NewReader(jsonStruct(doc)), // Document body
		DocumentID: "1",                                // Document ID
		Refresh:    "true",                             // Refresh
	}

	res, err := req.Do(ctx, es)
	if err != nil {
		log.Fatalf("Error getting response: %s", err)
	}
	defer res.Body.Close()

	return res
}

// 关键词搜索文档
func KeySearchDocument(reader io.Reader, langIndex string) (int, []model.Document, error) {
	// 1. 初始化
	es, _ := getEsCLient()

	ctx := context.Background()

	// 2. 查询构造
	req := esapi.SearchRequest{
		Index: []string{langIndex},
		Body:  reader,
	}

	// 3. 查询执行
	res, err := req.Do(ctx, es)
	if err != nil {
		log.Fatalf("Error getting response: %s", err)
		return 0, nil, err
	}
	defer res.Body.Close()

	if res.IsError() {
		log.Fatalf("%s ERROR search document\n", res.Status())
		return 0, nil, errors.New("ERROR search document")
	} else {
		var resMap map[string]interface{}
		if err := json.NewDecoder(res.Body).Decode(&resMap); err != nil {
			log.Fatalf("Error parsing the response body: %s\n", err)
			return 0, nil, errors.New("Error parsing the response body")
		} else {
			var retDocs []model.Document
			// 搜索结果总数
			total := resMap["hits"].(map[string]interface{})["total"].(map[string]interface{})["value"].(float64)

			hits := resMap["hits"].(map[string]interface{})["hits"].([]interface{})

			// 随机种子设置
			rand.Seed(time.Now().Unix())

			for _, hit := range hits {
				id := hit.(map[string]interface{})["_id"].(string)
				idInt, _ := strconv.Atoi(id)
				title := hit.(map[string]interface{})["_source"].(map[string]interface{})["title"].(string)
				highlightContent := hit.(map[string]interface{})["highlight"].(map[string]interface{})["content"]
				// 生成随机下标
				randContentIndex := rand.Intn(len(highlightContent.([]interface{})))
				content := highlightContent.([]interface{})[randContentIndex].(string)

				retDocs = append(retDocs, model.Document{
					ID:      idInt,
					Title:   title,
					Content: content,
				})
			}
			return int(total), retDocs, nil
		}
	}
}

// 全文检索文档
func FullSearchDocument(reader io.Reader, langIndex string) (int, []model.Document, error) {
	// 1. 初始化
	es, _ := getEsCLient()

	ctx := context.Background()

	// 2. 查询构造
	req := esapi.SearchRequest{
		Index: []string{langIndex},
		Body:  reader,
	}

	// 3. 查询执行
	res, err := req.Do(ctx, es)
	if err != nil {
		log.Fatalf("Error getting response: %s", err)
	}
	defer res.Body.Close()

	if res.IsError() {
		log.Fatalf("%s ERROR search document\n", res.Status())
	} else {
		var resMap map[string]interface{}
		if err := json.NewDecoder(res.Body).Decode(&resMap); err != nil {
			log.Printf("Error parsing the response body: %s\n", err)
		} else {
			log.Print(resMap["hits"].(map[string]interface{})["hits"].([]interface{}))

		}
	}
	return 0, nil, err
}

func jsonStruct(doc model.Document) string {
	docStruct := &model.Document{
		Title:   doc.Title,
		Content: doc.Content,
	}

	b, err := json.Marshal(docStruct)
	if err != nil {
		fmt.Println("json.Marshal ERROR:", err)
		return string(err.Error())
	}
	return string(b)
}
