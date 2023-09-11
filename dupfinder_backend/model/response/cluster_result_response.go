package response

type ClusterResultResponse struct {
	ClusterItems []ClusterItem `json:"clusters"` // 聚类结果
}

type ClusterItem struct {
	DocCount   int      `json:"doc_count"`    // 聚类文档数
	NearestDoc []string `json:"nearest_docs"` // 距离最近文档
}
