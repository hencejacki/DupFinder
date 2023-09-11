package initialize

import (
	"dupbackend/api"
	"log"

	"github.com/gin-gonic/gin"
)

// 初始化路由
func InitRouter() *gin.Engine {
	router := gin.Default()

	// API分组
	router.Group("/api")
	handlers := api.Handler
	{
		router.GET("/search", handlers.HomeApi.Search)
		router.POST("/dupcheck/file", handlers.DupCheckApi.CompareFile)
		router.POST("/dupcheck/txt", handlers.DupCheckApi.CompareTxt)
		router.GET("/cluster", handlers.GetClusterResult)
		router.POST("/GPT", handlers.GoGet)
	}

	log.Println("[Router]: register success")
	return router
}
