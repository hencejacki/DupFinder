package api

import (
	"dupbackend/global"
	"dupbackend/model/request"

	"github.com/gin-gonic/gin"
)

type ClusterResApi struct{}

// 获取聚类结果API
func (c *ClusterResApi) GetClusterResult(g *gin.Context) {
	// 1. 绑定请求参数
	var req request.ClusterResultRequest
	_ = g.ShouldBindQuery(&req)

	// 2. TODO: 校验参数

	// 3. 业务处理
	res, err := clusterService.GetClusterResult(req)
	if err != nil {
		global.BadResponse(g, err)
	} else {
		global.SuccessResponse(g, res)
	}
}
