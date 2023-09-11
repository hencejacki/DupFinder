package global

import (
	"dupbackend/model/session"
	"errors"
	"log"
)

type SessionHandler struct {
	sessions       []session.ChatSession // 会话集合
	currentSession int16                 // 当前会话
}

// 新建会话
func (sh *SessionHandler) NewSession() error {
	session, err := session.CreateEmptySession()
	if err != nil {
		return err
	}

	sh.sessions = append(sh.sessions, session)
	sh.currentSession += 1
	return nil
}

// 获取当前会话
func (sh *SessionHandler) CurrentSession() (session.ChatSession, error) {
	if len(sh.sessions) == 0 {
		if err := sh.NewSession(); err != nil {
			log.Fatalf("[Session] Get failed: %v", err.Error())
			return session.ChatSession{}, err
		}
	}

	return sh.sessions[sh.currentSession], nil
}

// 切换会话
func (sh *SessionHandler) SelectSession(idx int16) error {
	if idx >= int16(len(sh.sessions)) {
		log.Println("[Session] invalid select")
		return errors.New("")
	}
	sh.currentSession = idx
	return nil
}

// 更新会话
func (sh *SessionHandler) UpdateSession(session *session.ChatSession) {
	sh.sessions[sh.currentSession] = *session
}
