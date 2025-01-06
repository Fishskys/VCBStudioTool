# VCBStudioTool
一个VCBStudio压制资源整理工具，批量整理剧集文件和SPs文件

A tool for VCBStudio Source，sort session and SPs files

## 功能
* 批量整理剧集文件
* 按照PLEX能识别的方式分三类（Interviews、Trailers、Other）整理SPs
整理前文件结构

| PLEX文件夹 | 特典分类名称                                        |
| ---------- | --------------------------------------------------- |
| Interviews | IV                                                  |
| Trailers   | Preview、Web Preview、CM、SPOT、PV、Trailer、Teaser |
| Other      | Menu、NCOP、NCED 等其文件                           |



整理前文件结构
```
├── VCBStudio DIR
│   ├── Source DIR 1
│   │   ├── CDs/
│   │   ├── Scans/
│   │   ├── SPs/
│   │   ├── Sessions files
│   │   ├── ......
│   ├── Source DIR 2
│   │   ├── ......
```
整理后文件结构
```
├── VCBStudio DIR
│   ├── Source DIR 1
│   │   ├── CDs/
│   │   ├── Scans/
│   │   ├── Session/
│   │   ├── Interviews/
│   │   ├── Trailers/
│   │   ├── Other/
│   ├── Source DIR 2
│   │   ├── ......
```

## 使用方法
将VCBStudioTool.sh文件第13、14行修改为自己的目录，然后运行即可

## 致谢
感谢[mikusa](https://www.himiku.com/archives/how-i-organize-my-animation-library.html)提供的整理思路

