package global

import (
	"dupbackend/config"
	"net/http"

	"github.com/elastic/go-elasticsearch/v8"
	"gorm.io/gorm"
)

var (
	GVA_ES          *elasticsearch.Client // elasticsearch客户端
	GVA_ES_CONFIG   *config.EsConfig      // ESconfig
	GVA_EN_STWDS    []string              // 英文停用词表
	GVA_ZH_STWDS    []string              // 中文停用词表
	GVA_DB          *gorm.DB              // 数据库
	GVA_HTTP_CLIENT *http.Client          // HTTP Client
	GVA_GPT_REQUEST *http.Request         // GPT 请求
	GVA_GPT_CONFIG  *config.GPTConfig     // GPT 配置
	GVA_GPT_SESSION *SessionHandler       // GPT Session管理
)
