package service

import (
	"dupbackend/global"
	"dupbackend/model"
	"dupbackend/model/request"
	"dupbackend/model/response"
	"errors"
	"log"
	"strings"
)

// 聚类结果业务层
type ClusterResultService struct{}

func (c *ClusterResultService) GetClusterResult(req request.ClusterResultRequest) (*response.ClusterResultResponse, error) {
	// 1. 校验参数
	if req.Lang != "zh" && req.Lang != "en" {
		return nil, errors.New("[参数错误]: 语言选择有误")
	}

	// 2. 查询数据库
	var docClusters []model.DocumentCluster
	err := global.GVA_DB.Order("doc_count desc").Where("lang = (?) and cluster_type = (?)", req.Lang, req.ClusterKinds).Select([]string{"doc_count", "nearest_doc"}).Find(&docClusters).Error
	if err != nil {
		log.Fatalln("[MySQL-ClusterResultService]: Query failed: ", err.Error())
		return nil, errors.New("查询失败")
	}

	// 3. 校验
	if len(docClusters) == 0 {
		return nil, errors.New("查询为空")
	}

	// 4. 包装
	var clusterItems []response.ClusterItem
	for _, v := range docClusters {
		// 处理Nearest Doc
		nearestDoc := strings.Split(strings.TrimRight(strings.TrimLeft(v.NearestDoc, "["), "]"), " ")
		item := response.ClusterItem{
			DocCount:   v.DocCount,
			NearestDoc: nearestDoc,
		}
		clusterItems = append(clusterItems, item)
	}

	return &response.ClusterResultResponse{
		ClusterItems: clusterItems,
	}, nil
}
