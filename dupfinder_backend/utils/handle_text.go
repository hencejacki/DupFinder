package utils

import (
	"dupbackend/global"
	"fmt"
	"log"
	"math"
	"regexp"
	"strconv"
	"strings"
)

// cSpell: disable

// 替换特殊字符
func RemoveSpecialCharacter(text string, lang string) string {
	var cleanText string
	switch lang {
	case "en":
		regex := regexp.MustCompile("[^a-zA-Z0-9]+")
		cleanText = regex.ReplaceAllString(text, " ")
		break
	case "zh":
		regex := regexp.MustCompile("[^\u4e00-\u9fa5a-zA-Z0-9]+")
		cleanText = regex.ReplaceAllString(text, " ")
		break
	default:
		break
	}
	return cleanText
}

// 删除停用词
func RemoveStopWords(tokens []string, lang string) []string {
	if len(tokens) == 0 {
		return tokens
	}
	var filterTokens []string
	switch lang {
	case "en":
		for _, token := range tokens {
			if !contains(global.GVA_EN_STWDS, token) {
				filterTokens = append(filterTokens, token)
			}
		}
		break
	case "zh":
		for _, token := range tokens {
			if !contains(global.GVA_ZH_STWDS, token) {
				filterTokens = append(filterTokens, token)
			}
		}
		break
	default:
		log.Fatalf("Error language: [%s]", lang)
		break
	}
	return filterTokens
}

// 提取最长公共字符串数组
func GetMaxCommonStringArray(str1 []string, str2 []string) []string {
	var retArray []string
	if len(str1) == 0 || len(str2) == 0 {
		return retArray
	} else if len(str1) == 0 {
		return str2
	} else if len(str2) == 0 {
		return str1
	}

	// 使用 map 存储 arr1 中的元素
	set := make(map[string]bool)
	for _, str := range str1 {
		set[str] = true
	}

	// 遍历 arr2，判断元素是否在 set 中存在
	for _, str := range str2 {
		if set[str] {
			retArray = append(retArray, str)
		}
	}

	return retArray
}

// 对字符串数组去重
func DiffStringArray(strs []string) []string {
	set := make(map[string]bool)
	for _, str := range strs {
		if !set[str] {
			set[str] = true
		}
	}
	keys := make([]string, 0, len(set))
	for k := range set {
		keys = append(keys, k)
	}
	return keys
}

// 获取词频向量
func GetTFVector(target []string, pattern []string) []float64 {
	var tfVec []float64
	for _, str := range pattern {
		tf := getTF(target, str)
		if tf == 0 {
			tfVec = append(tfVec, 0)
		} else {
			tfVec = append(tfVec, 1+math.Log10(float64(tf)))
		}
	}
	return tfVec
}

// 获取词频
func getTF(target []string, str string) int {
	count := 0
	for _, s := range target {
		if strings.Compare(s, str) == 0 {
			count++
		}
	}
	return count
}

// 归一化向量
func NormalizeVector(vec []float64) []float64 {
	var retArray []float64

	mod := getVectorMod(vec)

	for _, v := range vec {
		retArray = append(retArray, v/mod)
	}
	return retArray
}

// 求得余弦距离
func GetCosDistance(vec1 []float64, vec2 []float64) (float64, string) {
	n := len(vec1)
	var res float64
	for i := 0; i < n; i++ {
		res += (vec1[i] * vec2[i])
	}
	if res > 1 {
		res = 1.0
	}
	tmp, _ := strconv.ParseFloat(fmt.Sprintf("%.4f", res), 64)
	return tmp, fmt.Sprintf("%.2f%%", tmp*100)
}

// 求得向量的模
func getVectorMod(vec []float64) float64 {
	var sum float64
	for _, v := range vec {
		sum += math.Pow(v, 2)
	}
	return math.Sqrt(sum)
}

// 检查字符串切片中是否包含指定字符串
func contains(strs []string, str string) bool {
	for _, s := range strs {
		if s == str {
			return true
		}
	}
	return false
}
