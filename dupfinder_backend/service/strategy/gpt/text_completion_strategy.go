package gpt

import (
	"dupbackend/constant"
	"dupbackend/global"
	"encoding/json"
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/url"
	"strings"
)

type TextCompletionStrategy struct{}

// 获取文本补全服务
func (t *TextCompletionStrategy) GoGet(prompt string, idx int16) (string, error) {
	u, ok := url.Parse(constant.GPT_TC_URL)
	if ok != nil {
		log.Fatalln("[Error TextCompletion]: error parse url from ", constant.GPT_TC_URL)
		return "", ok
	}

	global.GVA_GPT_REQUEST.URL = u
	// 构造请求体
	req := map[string]interface{}{
		"model":       "text-davinci-003",
		"prompt":      prompt,
		"temperature": 0.7,
		"max_tokens":  256,
	}
	reqJson, err := json.Marshal(req)
	if err != nil {
		log.Fatalln("[Error serialize request body]: ", err.Error())
		return "", err
	}
	global.GVA_GPT_REQUEST.Body = io.NopCloser(strings.NewReader(string(reqJson)))
	defer global.GVA_GPT_REQUEST.Body.Close()

	// 请求API
	resp, ok := global.GVA_HTTP_CLIENT.Do(global.GVA_GPT_REQUEST)
	if ok != nil {
		log.Fatalln("[Error request API]: ", ok.Error())
		return "", ok
	}
	defer resp.Body.Close()

	// 解析请求
	var resMap map[string]interface{}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln("[Error read response body]: ", err.Error())
		return "", err
	}
	// 反序列化
	if deserializeErr := json.Unmarshal(body, &resMap); deserializeErr != nil {
		log.Fatalln("[Error deserialize response body]: ", deserializeErr.Error())
		return "", deserializeErr
	}
	if _, exists := resMap["choices"]; !exists {
		log.Fatalln("[Error get correct response]: ")
		return "", errors.New("Error get correct response!")
	}
	responseText := resMap["choices"].([]interface{})[0].(map[string]interface{})["text"].(string)
	return responseText, nil
}
