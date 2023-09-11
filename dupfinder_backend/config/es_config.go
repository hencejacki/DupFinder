package config

type EsConfig struct {
	LangIndexs map[string]bool // 支持索引文档
	SearchType map[string]bool // 支持搜索类型
}
