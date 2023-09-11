package initialize

import (
	"dupbackend/config"
	"dupbackend/global"
)

func InitGPT() {
	// 对话模型支持初始化
	global.GVA_GPT_CONFIG = &config.GPTConfig{
		Models: map[string]bool{
			"tc": false,
			"cc": true,
			"ig": false,
		},
	}
}
