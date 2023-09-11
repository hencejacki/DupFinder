package config

import "fmt"

// 数据库配置
type DBConfig struct {
	Path     string // 路径
	Port     string // 端口
	DbName   string // 数据库名
	Config   string // 高级配置
	UserName string // 用户名
	Password string // 密码
}

func (d *DBConfig) Dsn() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?%s", d.UserName, d.Password, d.Path, d.Port, d.DbName, d.Config)
}
