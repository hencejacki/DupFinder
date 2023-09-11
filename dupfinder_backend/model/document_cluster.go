package model

import "gorm.io/gorm"

// 文档聚类结果
type DocumentCluster struct {
	gorm.Model
	Label       string `gorm:"comment:聚类标签"` // 聚类标签
	NearestDoc  string `gorm:"comment:聚类文档"` // 距离最近5文档标题
	ClusterType int    `gorm:"comment:聚类类型"` // 聚类类型: 5,20,25
	DocCount    int    `gorm:"comment:文档数量"` // 聚类文档数
	Lang        string `gorm:"comment:文档语言"` // 聚类文档语言
}
