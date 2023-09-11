package service

import (
	"dupbackend/global"
	"dupbackend/model/request"
	"dupbackend/model/response"
	"dupbackend/service/strategy"
	"errors"
	"log"
)

type GPTService struct{}

func (g *GPTService) GoGet(req *request.GPTRequest) (*response.GPTResponse, error) {
	// 1. 校验参数-----TODO: 校验sessionIdx合法性
	if req.Question == "" || len(req.Question) == 0 {
		return nil, errors.New("[GoGet]: 参数错误")
	}
	if _, exists := global.GVA_GPT_CONFIG.Models[req.Model]; !exists {
		return nil, errors.New("[GoGet]: 请求模型不存在")
	}

	// 2. 请求API
	var apiContext strategy.GPTContext
	exec := apiContext.InitGPTContext(req.Model)

	answer, err := exec.GoGet(req.Question, req.SessionIdx)
	if err != nil {
		log.Fatalln("[Error Get Response]: ", err.Error())
		return nil, err
	}
	ret := &response.GPTResponse{
		Answer: answer,
	}
	return ret, nil
}
