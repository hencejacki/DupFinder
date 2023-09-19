package gpt

import (
	"dupbackend/constant"
	"dupbackend/global"
	"dupbackend/model/session"
	"encoding/json"
	"errors"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

type ChatCompletionStrategy struct{}

// 获取聊天服务
func (t *ChatCompletionStrategy) GoGet(prompt string, idx int16) (string, error) {
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

	// 构造请求体
	var messages []session.Messages
	for _, v := range currentSession.Messages {
		messages = append(messages, session.Messages{
			Content: v.Content,
			Role:    v.Role,
		})
	}
	reqBody := map[string]interface{}{
		"model":             "gpt-3.5-turbo",
		"messages":          messages,
		"temperature":       0.5,
		"presence_penalty":  0,
		"frequency_penalty": 0,
		"top_p":             1,
	}

	// 序列化请求
	reqJson, err := json.Marshal(reqBody)
	if err != nil {
		log.Println("[Error serialize request body]: ", err.Error())
		return "", err
	}

	// 创建Request
	req, err := http.NewRequest("POST", constant.GPT_CC_URL, strings.NewReader(string(reqJson)))
	if err != nil {
		log.Println("[Error create request]: ", err.Error())
		return "", err
	}

	// 设置头部
	req.Header.Set("Authorization", constant.GPT_API_KEY)
	req.Header.Set("Content-Type", "application/json")

	// 请求API
	resp, ok := global.GVA_HTTP_CLIENT.Do(req)
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
	currentSession.Messages[len(currentSession.Messages)-1].Content = responseMsg
	// 更新会话
	global.GVA_GPT_SESSION.UpdateSession(&currentSession)

	return responseMsg, nil
}

/*
standard format:
{
    "messages": [
        {
            "role": "system",
            "content": "\nYou are ChatGPT, a large language model trained by OpenAI.\nKnowledge cutoff: 2021-09\nCurrent model: gpt-3.5-turbo\nCurrent time: 2023/9/9 15:41:11\n"
        },
        {
            "role": "user",
            "content": "指针和引用区别是什么"
        }
    ],
    "model": "gpt-3.5-turbo",
    "temperature": 0.5,
    "presence_penalty": 0,
    "frequency_penalty": 0,
    "top_p": 1
}

construct format style:
{
    "frequency_penalty": 0,
    "messages": [
        {
            "content": "你好",
            "role": "user"
        },
        {
            "content": "",
            "role": "assistant"
        }
    ],
    "model": "gpt-3.5-turbo",
    "presence_penalty": 0,
    "temperature": 0.5,
    "top_p": 1
}
*/
