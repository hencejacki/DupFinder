package request

// 搜索请求
type SearchRequest struct {
	Keyword string `form:"keyword"`
	From    int    `form:"from"`
	Size    int    `form:"size"`
	Lang    string `form:"lang"`
	Type    string `form:"type"`
}
