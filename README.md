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
**建议硬链接后使用**

默认重命名功能关闭，如需开启，请修改ifRename和ifRenameSPs为1

下载VCBStudioTool.sh文件，修改VCBStudio_dir、ignore_dirs、ifRename和ifRenameSPs，然后运行即可。



## 更新日志
### 2025.1.14
新增功能：

1.支持各种不同深度的文件夹，只需将所有资源文件放在VCBStudio DIR即可

2.对文件夹重命名，默认格式：重命名前:[VCBStudio] xx [type] 重命名后:xx [type]

3.对文件重命名，举例：重命名前:[DMG&VCB-Studio] Tenki no Ko [Ma10p_1080p][x265_flac].mka 重命名后:Tenki no Ko [Ma10p_1080p].mka，即保留基本命名和和剧集数/文件信息（其实是剧集名字后第一个中括号）

4.新增ignore_dirs，可忽略多个文件夹

