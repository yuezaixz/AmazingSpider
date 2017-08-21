
# AmazingSpider

<p align="left">
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/swift-4.0-brightgreen.svg"/></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-ready-orange.svg"></a>
<a href=""><img src="https://img.shields.io/cocoapods/l/Kingfisher.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/platform-macos-blue.svg"/></a>
</p>

## 功能
Swift实现命令行工具，用于自动整理iOS项目中的本地化文案

## 环境

* Xcode9
* Swift4
* macOS

## 编译安装

```bash

> git clone https://github.com/yuezaixz/AmazingSpider.git
> cd AmazingSpider
> ./install.sh

```

提示成功后在命令行可以直接输入AmazingSpider调用脚本

```bash

> AmazingSpider
Usage: AmazingSpider [options]
  -p, --path:
      paths which should run spider.
  -h, --help:
      Prints a help message.
  -v, --version:
      Print version.
  -e, --exclude:
      Directorys which exclude.
  -o, --output:
      path which should save result.

```

## 使用

### 帮助文档

查看帮助

```bash

> AmazingSpider
Usage: AmazingSpider [options]
  -p, --path:
      paths which should run spider.
  -h, --help:
      Prints a help message.
  -v, --version:
      Print version.
  -e, --exclude:
      Directorys which exclude.
  -o, --output:
      path which should save result.

```

### 检索项目的本地资源文件

开始检索

```bash

> AmazingSpider -p ~/Workspaces/Runmove_Git/ -e Pods 3rdParty -o Test.csv
Searching path:/Users/David_Woo/Workspaces/Runmove_Git/
> ls -al Test.csv
-rw-r--r--  1 David_Woo  staff  341823  8 21 11:38 Test.csv

```

### 结果

用Numbers打开

![WX20170821-114154](http://7oxfjd.com2.z0.glb.qiniucdn.com/2017-08-21-WX20170821-114154.png)


