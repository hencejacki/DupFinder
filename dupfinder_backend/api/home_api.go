package api

import (
	"dupbackend/global"
	"dupbackend/model/request"
	"net/http"

	"github.com/gin-gonic/gin"
)

type HomeApi struct{}

func (h *HomeApi) Test(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
	})
}

// 搜索文档API
func (h *HomeApi) Search(c *gin.Context) {
	// 1. 获取请求体
	var req request.SearchRequest
	_ = c.ShouldBindQuery(&req)

	// 2. TODO: 参数校验

	// 3. 业务逻辑处理
	res, err := searchService.SearchDoc(req)
	if err != nil {
		global.BadResponse(c, err)
	} else {
		global.SuccessResponse(c, res)
	}
}
