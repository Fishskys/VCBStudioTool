# VCBStudioTool
一个VCBStudio压制资源整理工具，批量整理剧集文件和SPs文件

A tool for VCBStudio Source，sort session and SPs files


## 功能
* 批量整理剧集文件
* 按照PLEX能识别的方式分三类（Interviews、Trailers、Other）整理SPs
* 对目录和文件重命名

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
**建议结合硬链接工具如Hlink一同使用以筛选不需要整理的文件**

用户配置文件为usr.conf，根据提示修改配置，将VCBStudioTool.sh与usr.conf放在同一目录下运行即可。

默认重命名功能关闭，如需开启，按照注释修改usr.conf配置文件


## [更新日志](./updatelog.md)

## 致谢
感谢[mikusa](https://www.himiku.com/archives/how-i-organize-my-animation-library.html)提供的整理思路

