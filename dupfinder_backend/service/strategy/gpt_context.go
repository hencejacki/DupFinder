package strategy

import (
	"dupbackend/service/strategy/gpt"
)

type GPTContext struct {
	strategy gpt.GPTStrategy
}

const (
	textCompletion  = "tc" // 文本补全
	chatCompletion  = "cc" // 聊天补全
	imageGeneration = "ig" // 图片生成
)

// 初始化GPT上下文
func (g *GPTContext) InitGPTContext(gptType string) *GPTContext {
	var gptContext GPTContext
	switch gptType {
	case textCompletion:
		break
	case chatCompletion:
		gptContext.strategy = new(gpt.ChatCompletionStrategy)
		break
	case imageGeneration:
		break
	default:
		break
	}
	return &gptContext
}

func (g *GPTContext) GoGet(prompt string, idx int16) (string, error) {
	return g.strategy.GoGet(prompt, idx)
}
