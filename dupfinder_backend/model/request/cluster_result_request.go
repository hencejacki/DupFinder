package request

type ClusterResultRequest struct {
	Lang         string `form:"lang"`          // 聚类语言
	ClusterKinds int    `form:"cluster_kinds"` // 聚类数: 5,20,30
}
