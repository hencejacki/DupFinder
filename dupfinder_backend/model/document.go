package model

type Document struct {
	ID      int    `json:"id"`      // 文档ID
	Title   string `json:"title"`   // 文档标题
	Content string `json:"content"` // 文档内容
}

// 导入至ES时使用
type Documents struct {
	EN_doc []InsertDocument
	ZH_doc []InsertDocument
}

type InsertDocument struct {
	Title   string `json:"title"`
	Content string `json:"content"`
}
