package session

import (
	"dupbackend/constant"
	"log"
	"time"

	uuid "github.com/nu7hatch/gouuid"
)

// API Use
type Messages struct {
	Content string `json:"content"` // 消息
	Role    string `json:"role"`    // 消息日期
}

type ChatMessage struct {
	Id      string // 消息ID
	Content string // 消息
	Date    string // 消息日期
	Role    string // 角色
}

type ChatSession struct {
	Id         string        // session ID
	Topic      string        // 主体
	Messages   []ChatMessage // 会话消息
	LastUpdate int64         // 上次更新时间
}

// 创建空会话
func CreateEmptySession() (ChatSession, error) {
	u, err := uuid.NewV4()
	if err != nil {
		log.Fatalf("[Session] Create failed%v", err.Error())
		return ChatSession{}, err
	}
	return ChatSession{
		Id:         u.String(),
		Topic:      constant.DEFAULT_TOPIC,
		Messages:   []ChatMessage{},
		LastUpdate: time.Now().Unix(),
	}, nil
}

func CreateNewMessage(message string, role string) ChatMessage {
	u, err := uuid.NewV4()
	if err != nil {
		log.Println("[Message] Create failed: ", err.Error())
		return ChatMessage{}
	}
	return ChatMessage{
		Id:      u.String(),
		Content: message,
		Date:    time.Now().Format("2006-01-02 15:04:05"),
		Role:    role,
	}
}
