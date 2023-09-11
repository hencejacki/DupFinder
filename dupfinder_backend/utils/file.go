package utils

import (
	"dupbackend/constant"
	"dupbackend/model"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

// 读取文件并返回
func ReadDocument(path string) model.InsertDocument {
	f, err := ioutil.ReadFile(path)
	if err != nil {
		log.Println("file read fail.")
	}
	return model.InsertDocument{
		Title:   filepath.Base(path),
		Content: string(f),
	}
}

// 读取文档并返回中英文model
func ReadDocuments() model.Documents {
	var ret model.Documents
	// 1. 中文文档读取
	var zh_docs []model.InsertDocument
	zh_basePath := GetProjectDir(constant.ZH_DOC_PATH)
	zh_files, err := ioutil.ReadDir(zh_basePath)
	if err != nil {
		log.Println("read chinese doc fail.")
	}
	for _, file := range zh_files {
		if !file.IsDir() {
			zh_docs = append(zh_docs, ReadDocument(filepath.Join(zh_basePath, file.Name())))
		}
	}
	// 2. 英文文档读取
	var en_docs []model.InsertDocument
	en_basePath := GetProjectDir(constant.EN_DOC_PATH)
	en_files, err := ioutil.ReadDir(en_basePath)
	if err != nil {
		log.Println("read english doc fail.")
	}
	for _, file := range en_files {
		if !file.IsDir() {
			en_docs = append(en_docs, ReadDocument(filepath.Join(en_basePath, file.Name())))
		}
	}
	// 3. set
	ret.EN_doc = en_docs
	ret.ZH_doc = zh_docs
	return ret
}

// 读取文件内容
func GetFileContent(path string) string {
	// 获取文件绝对路径
	fileBasePath := GetProjectDir(path)
	if fileInfo, err := os.Stat(fileBasePath); err != nil {
		log.Fatalf("Error get file path [%s]: [%s]", fileBasePath, err.Error())
		os.Exit(0)
	} else {
		// 文件夹不可读
		if fileInfo.IsDir() {
			log.Fatal("Error read file from a dir")
			os.Exit(0)
		} else {
			file, err := ioutil.ReadFile(fileBasePath)
			if err != nil {
				log.Fatalf("Error read file [%s]: [%s]", fileBasePath, err.Error())
				os.Exit(0)
			}
			return string(file)
		}
	}
	return ""
}

// 获取项目根目录
func GetProjectDir(path string) string {
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal("Eet current path error", err.Error())
	}
	index := strings.Index(dir, "dupfinder_backend") + len("dupfinder_backend")
	root := dir[:index]
	return filepath.Join(root, path)
}
