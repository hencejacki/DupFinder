package api

import (
	"dupbackend/global"
	"dupbackend/model/request"
	"log"
	"mime/multipart"

	"github.com/gin-gonic/gin"
)

type DupCheckApi struct{}

// 读取文件内容
func (d *DupCheckApi) readFromMultipartFile(doc *multipart.FileHeader) (string, error) {
	file, err := doc.Open()
	if err != nil {
		return "", err
	}
	defer file.Close()
	buffer := make([]byte, doc.Size)
	_, err = file.Read(buffer)
	return string(buffer), err
}

// 查重文档API
func (d *DupCheckApi) CompareFile(c *gin.Context) {
	// 1. 绑定请求体
	var req request.CompareFileRequest
	_ = c.ShouldBind(&req)

	// 2. 读取文件内容
	originalDocContent, err := d.readFromMultipartFile(req.OriginalDoc)
	if err != nil {
		log.Fatalf("Error read original doc content: [%s]\n", err.Error())
		global.BadResponse(c, err)
		return
	}

	compareDocContent, err := d.readFromMultipartFile(req.CompareDoc)
	if err != nil {
		log.Fatalf("Error read compare doc content: [%s]\n", err.Error())
		global.BadResponse(c, err)
		return
	}

	// 3. 查重业务逻辑
	res, err := compareService.DupCheck(originalDocContent, compareDocContent, req.Lang)
	if err != nil {
		log.Fatalf("Error duplicate check: [%s]\n", err.Error())
		global.BadResponse(c, err)
		return
	}

	global.SuccessResponse(c, res)
}

// 查重文本API
func (d *DupCheckApi) CompareTxt(c *gin.Context) {
	// 1. 绑定请求体
	var req request.CompareTextRequest
	_ = c.ShouldBind(&req)

	// 3. 查重业务逻辑
	res, err := compareService.DupCheck(req.OriginalTxt, req.CompareTxt, req.Lang)
	if err != nil {
		log.Fatalf("Error duplicate check: [%s]\n", err.Error())
		global.BadResponse(c, err)
		return
	}

	global.SuccessResponse(c, res)
}
