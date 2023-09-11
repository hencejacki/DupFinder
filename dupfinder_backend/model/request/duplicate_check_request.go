package request

import "mime/multipart"

// 文件查重
type CompareFileRequest struct {
	OriginalDoc *multipart.FileHeader `form:"original_doc"` // 原始文档
	CompareDoc  *multipart.FileHeader `form:"compare_doc"`  // 比较文档
	Lang        string                `form:"lang"`         // 文档语言
}

// 文本查重
type CompareTextRequest struct {
	OriginalTxt string `form:"original_txt"` // 原始文本
	CompareTxt  string `form:"compare_txt"`  // 比较文本
	Lang        string `form:"lang"`         // 文档语言
}
