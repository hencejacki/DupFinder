package gpt

import (
	"dupbackend/constant"
	"dupbackend/global"
	"dupbackend/model/session"
	"encoding/json"
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/url"
	"strings"
	"time"
)

type ChatCompletionStrategy struct{}

// 获取聊天服务
func (t *ChatCompletionStrategy) GoGet(prompt string, idx int16) (string, error) {
	u, ok := url.Parse(constant.GPT_CC_URL)
	if ok != nil {
		log.Println("[Error ChatCompletion]: error parse url from ", constant.GPT_TC_URL)
		return "", ok
	}

	global.GVA_GPT_REQUEST.URL = u

	// 获取会话信息
	sErr := global.GVA_GPT_SESSION.SelectSession(idx)
	if sErr != nil {
		log.Println("[Error ChatCompletion]: error change session ", sErr.Error())
		return "", nil
	}
	currentSession, cErr := global.GVA_GPT_SESSION.CurrentSession()
	if cErr != nil {
		log.Println("[Error ChatCompletion]: error get session ", cErr.Error())
		return "", nil
	}

	userMessage := session.CreateNewMessage(prompt, "user")
	botMessage := session.CreateNewMessage("", "assistant")

	// 引用传递slice，后文可改变botMessage内容
	currentSession.Messages = append(currentSession.Messages, userMessage, botMessage)
	currentSession.LastUpdate = time.Now().Unix()

	// 更新会话
	global.GVA_GPT_SESSION.UpdateSession(&currentSession)

	// 构造请求体
	req := map[string]interface{}{
		"model":             "gpt-3.5-turbo",
		"message":           currentSession.Messages,
		"temperature":       0.5,
		"presence_penalty":  0,
		"frequency_penalty": 0,
		"top_p":             1,
	}

	log.Println("[GPT Request]: ", req)

	// 序列化请求
	reqJson, err := json.Marshal(req)
	if err != nil {
		log.Println("[Error serialize request body]: ", err.Error())
		return "", err
	}
	global.GVA_GPT_REQUEST.Body = io.NopCloser(strings.NewReader(string(reqJson)))
	defer global.GVA_GPT_REQUEST.Body.Close()

	// 请求API
	resp, ok := global.GVA_HTTP_CLIENT.Do(global.GVA_GPT_REQUEST)
	if ok != nil {
		log.Println("[Error request API]: ", ok.Error())
		return "", ok
	}
	defer resp.Body.Close()

	// 解析请求
	var resMap map[string]interface{}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("[Error read response body]: ", err.Error())
		return "", err
	}
	// 反序列化
	if deserializeErr := json.Unmarshal(body, &resMap); deserializeErr != nil {
		log.Println("[Error deserialize response body]: ", deserializeErr.Error())
		return "", deserializeErr
	}
	if _, exists := resMap["choices"]; !exists {
		log.Println("[Error get correct response]: ")
		return "", errors.New("Error get correct response!")
	}
	// 信息提取
	responseMsg := resMap["choices"].([]interface{})[0].(map[string]interface{})["message"].(map[string]interface{})["content"].(string)

	log.Println("[GPT Response]: ", responseMsg)

	// 前文botMessage内容更新
	botMessage.Message = responseMsg

	return responseMsg, nil
}
