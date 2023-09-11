package initialize

import (
	"dupbackend/config"
	"dupbackend/constant"
	"dupbackend/global"
	"dupbackend/model"
	"log"
	"os"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func InitMySQL() {
	// 初始化数据库配置 TODO: yaml加载
	configure := &config.DBConfig{
		Path:     constant.MYSQL_PATH,
		Port:     constant.MYSQL_PORT,
		DbName:   constant.MYSQL_DBNAME,
		UserName: constant.MYSQL_USERNAME,
		Password: constant.MYSQL_PASSWORD,
		Config:   constant.MYSQL_CONFIG,
	}

	// 连接数据库
	db, err := gorm.Open(mysql.New(mysql.Config{
		DSN: configure.Dsn(),
	}), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error open database [%s]: [%s]", configure.Dsn(), err.Error())
		os.Exit(0)
	}
	log.Printf("[MySQL]: Open success\n")

	// 建立表结构
	if err := db.AutoMigrate(&model.DocumentCluster{}); err != nil {
		log.Fatalf("Error create table automatically: [%s]", err.Error())
		os.Exit(0)
	}

	log.Printf("[MySQL]: Table structure create success")

	global.GVA_DB = db
}
