package global

import (
	"dupbackend/constant"
	"dupbackend/model/response"
	"net/http"

	"github.com/gin-gonic/gin"
)

// 失败响应
func BadResponse(c *gin.Context, err error) {
	c.JSON(http.StatusBadRequest, &response.BaseResponse{
		Code: constant.ERROR,
		Msg:  err.Error(),
		Data: nil,
	})
}

// 成功响应
func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, &response.BaseResponse{
		Code: constant.SUCCESS,
		Msg:  "ok",
		Data: data,
	})
}
