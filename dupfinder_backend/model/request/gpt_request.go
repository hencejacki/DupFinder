package request

type GPTRequest struct {
	Question   string `form:"question"`   // 问题
	Model      string `form:"model"`      // 模型选择
	SessionIdx int16  `form:"sessionIdx"` // 会话索引
}
