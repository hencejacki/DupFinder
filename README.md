<div align="center">
 <image style="width:300px;height:300px" src="https://gitee.com/jackwalse/mypic/raw/master/img/logo_windows.jpg"></image> 
<div align="center">
<img src="https://img.shields.io/badge/Author-hence_jacki-blue"/>    
<img src="https://img.shields.io/github/license/hencejacki/DupFinder"/>    
</div>

# DupFinder

集搜索引擎、文本查重、文本聚类分析、GPT问答等于一身的混合百宝箱。

## 系统架构

![image-20230911151022568](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151022568.png)

## 界面展示

首页（亮色）

![image-20230911151051566](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151051566.png)

首页（暗色）

![image-20230911151126873](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151126873.png)

中文文档搜索结果

![image-20230911151154033](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151154033.png)

英文文档搜索结果

![image-20230911151211321](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151211321.png)

文档查重界面

![image-20230911151230729](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151230729.png)

![image-20230911151238026](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151238026.png)

中文文档查重结果

![image-20230911151254682](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151254682.png)

英文文档查重结果

![image-20230911151308389](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151308389.png)

聚类结果查看

![image-20230911151342064](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151342064.png)

GPT问答界面（待开发）

![image-20230911151851371](https://gitee.com/jackwalse/mypic/raw/master/img/image-20230911151851371.png)

## 使用

1. 克隆

~~~bash
git clone https://github.com/hencejacki/DupFinder.git
~~~

2. 后端启动

~~~bash
cd dupfinder_backend/
go build . && ./dupbackend.exe
# 对应平台构建编译即可
# go build . && ./dupbackend
~~~

3. 前端启动

~~~bash
cd dupfiner_frontend/
flutter run -d windows
# 对应平台运行即可
# flutter run -d %device_name
~~~

## Licence

[MIT](./LICENSE)





