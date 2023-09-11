package initialize

import (
	"dupbackend/config"
	"dupbackend/global"

	"github.com/elastic/go-elasticsearch/v8"
)

// 初始化elasticsearch
func InitES() error {
	var err error
	global.GVA_ES, err = elasticsearch.NewDefaultClient()
	global.GVA_ES_CONFIG = &config.EsConfig{
		LangIndexs: map[string]bool{
			"zh_docs": true,
			"en_docs": true,
		},
		SearchType: map[string]bool{
			"key":  true,
			"full": true,
		},
	}
	return err
}
