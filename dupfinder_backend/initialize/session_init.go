package initialize

import (
	"dupbackend/global"
	"log"
)

// 初始化会话
func InitSession() {
	global.GVA_GPT_SESSION = &global.SessionHandler{}
	err := global.GVA_GPT_SESSION.NewSession()
	if err != nil {
		log.Fatalln("[Session] Init failed")
	}
	global.GVA_GPT_SESSION.SelectSession(0)
}
