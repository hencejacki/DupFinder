package service

import (
	"dupbackend/model/response"
	"dupbackend/utils"
	"strings"

	"github.com/yanyiwu/gojieba"
)

type DuplicateCheckService struct{}

// 结论
const (
	SIMILARITY_0 = "完全不相似的文档"
	SIMILARITY_1 = "存在一些相同的内容或词汇，但整体上差异较大"
	SIMILARITY_2 = "文档之间有一定的相似性，但还存在较大差异"
	SIMILARITY_3 = "文档之间有较高的相似性，可能存在大部分相同的内容或结构"
	SIMILARITY_4 = "文档之间非常相似，可能存在少量变动或修改"
	SIMILARITY_5 = "文档之间几乎完全相同或仅有细微的差异"
)

// 处理文档
func (d *DuplicateCheckService) handleDoc1(docChannel chan<- []string, doc string, lang string) {
	// 1. 去除特殊字符
	cleanDoc := utils.RemoveSpecialCharacter(doc, lang)
	// 2. 大小写转换
	lowerDoc := strings.ToLower(cleanDoc)
	// 3. 分词
	tokenTool := gojieba.NewJieba()
	tokens := tokenTool.CutForSearch(lowerDoc, true)
	// TODO: 内存泄漏
	// defer tokenTool.Free()
	// 4. 停用词删除
	meaningFulTokens := utils.RemoveStopWords(tokens, lang)
	docChannel <- meaningFulTokens
}

// 处理文档
func (d *DuplicateCheckService) handleDoc2(docChannel chan<- []string, doc string, lang string) {
	// 1. 去除特殊字符
	cleanDoc := utils.RemoveSpecialCharacter(doc, lang)
	// 2. 大小写转换
	lowerDoc := strings.ToLower(cleanDoc)
	// 3. 分词
	tokenTool := gojieba.NewJieba()
	tokens := tokenTool.CutForSearch(lowerDoc, true)
	// TODO: 内存泄漏
	// defer tokenTool.Free()
	// 4. 停用词删除
	meaningFulTokens := utils.RemoveStopWords(tokens, lang)
	docChannel <- meaningFulTokens
}

// 查重业务逻辑
func (d *DuplicateCheckService) DupCheck(originalDoc string, compareDoc string, lang string) (*response.CompareResponse, error) {
	handleOriginalDocCh := make(chan []string)
	handlerCompareDocCh := make(chan []string)

	// 启动并发处理任务
	go d.handleDoc1(handleOriginalDocCh, originalDoc, lang)
	go d.handleDoc2(handlerCompareDocCh, compareDoc, lang)

	// 等待处理结果: originalDocRes([]string), compareDocRes([]string)
	originalDocRes := <-handleOriginalDocCh
	compareDocRes := <-handlerCompareDocCh
	defer close(handleOriginalDocCh)
	defer close(handlerCompareDocCh)
	// fmt.Println("originalDocRes: ", originalDocRes)
	// fmt.Println("compareDocRes: ", compareDocRes)
	// 5. 合并
	termSet := append(originalDocRes, compareDocRes...)
	// fmt.Println("Merge: ", termSet)

	// 6. 去重
	termSet = utils.DiffStringArray(termSet)
	// fmt.Println("Diff: ", termSet)

	// 7. 统计词频: 获取文档的向量表示
	originalDocVec := utils.GetTFVector(originalDocRes, termSet)
	compareDocVec := utils.GetTFVector(compareDocRes, termSet)
	// fmt.Println("originalDocVec: ", originalDocVec, "compareDocVec: ", compareDocVec)

	// 8. 正则化
	originalDocNormalize := utils.NormalizeVector(originalDocVec)
	compareDocNormalize := utils.NormalizeVector(compareDocVec)
	// fmt.Println("originalDocNormalize: ", originalDocNormalize, "compareDocNormalize: ", compareDocNormalize)

	// 8. 求取余弦距离 similarity: 原始相似度值, similarityFormatted: 百分比格式化相似度
	similarity, similarityFormatted := utils.GetCosDistance(originalDocNormalize, compareDocNormalize)

	// fmt.Println(similarity)

	// 9. 得出结论
	var conclusion string

	if similarity <= 0.1 {
		conclusion = SIMILARITY_0
	} else if similarity > 0.1 && similarity <= 0.3 {
		conclusion = SIMILARITY_1
	} else if similarity > 0.3 && similarity <= 0.5 {
		conclusion = SIMILARITY_2
	} else if similarity > 0.5 && similarity <= 0.7 {
		conclusion = SIMILARITY_3
	} else if similarity > 0.7 && similarity <= 0.9 {
		conclusion = SIMILARITY_4
	} else {
		conclusion = SIMILARITY_5
	}

	resp := &response.CompareResponse{
		Similarity: similarityFormatted,
		Conclusion: conclusion,
	}
	return resp, nil
}
