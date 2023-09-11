package api

import (
	"dupbackend/global"
	"dupbackend/model/request"

	"github.com/gin-gonic/gin"
)

type QuestionAnswerApi struct{}

func (q *QuestionAnswerApi) GoGet(c *gin.Context) {
	// 1. 绑定请求参数
	var req request.GPTRequest
	_ = c.ShouldBind(&req)

	// 2. 参数校验

	// 3. 请求服务
	resp, err := gptService.GoGet(&req)
	if err != nil {
		global.BadResponse(c, err)
	} else {
		global.SuccessResponse(c, resp)
	}
}
