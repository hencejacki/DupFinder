package response

type CompareResponse struct {
	Similarity string `json:"similarity"` // 相似度-百分比
	Conclusion string `json:"conclusion"` // 结论
}
