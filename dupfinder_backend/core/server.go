package core

import (
	"dupbackend/constant"
	Listen "dupbackend/constant"
	"dupbackend/global"
	"dupbackend/initialize"
	"dupbackend/utils"
	"log"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"net/http"
)

type server interface {
	ListenAndServe() error
}

func initServer(address string, router *gin.Engine) server {
	return &http.Server{
		Addr:           address,
		Handler:        router,
		ReadTimeout:    20 * time.Second,
		WriteTimeout:   20 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
}

// 初始化停用词表
func initStopWords() {
	global.GVA_EN_STWDS = strings.Split(utils.GetFileContent(constant.EN_STWDS_PATH), "\n")
	global.GVA_ZH_STWDS = strings.Split(utils.GetFileContent(constant.ZH_STWDS_PATH), "\n")
}

func RunServer() {
	// 初始化路由
	Router := initialize.InitRouter()

	// 初始化MySQL
	initialize.InitMySQL()

	// 初始化ES
	esErr := initialize.InitES()
	if esErr != nil {
		log.Fatalf("[Elastic Search]: Error initialize elasticsearch service: [%s]", esErr.Error())
		os.Exit(0)
	}
	log.Println("[Elastic Search]: init success on :9200.")
	log.Println(global.GVA_ES.Info())

	// 初始化停用词表
	initStopWords()

	// 初始化Web服务器
	s := initServer(Listen.PORT, Router)

	// 初始化HTTP Client
	global.GVA_HTTP_CLIENT = &http.Client{}

	// 初始化GPT请求
	initialize.InitGPT()

	// 初始化GPT Session
	initialize.InitSession()

	log.Println("[GPT init]: init success.")

	log.Println("[Server]: listen on: ", Listen.PORT)

	serveErr := s.ListenAndServe()
	if serveErr != nil {
		log.Fatalln(serveErr.Error())
	}
}
