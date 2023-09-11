package gpt

type GPTStrategy interface {
	GoGet(string, int16) (string, error)
}
