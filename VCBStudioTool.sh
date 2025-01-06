#!/bin/bash

# 做一个VCBStudio资源库的批量整理脚本
# 资源类型：
# PLEX文件夹	 特典分类名称
# Interviews	IV
# Trailers	    Preview、Web Preview、CM、SPOT、PV、Trailer、Teaser
# Other	        Menu、NCOP、NCED 等其他无意义文件

# 识别特典名称中的关键词例如IV、Preview、Web Preview、CM、SPOT、PV、Trailer、Teaser
# 将识别到的特典放入对应的文件夹，例如IV放入Interviews文件夹，Preview放入Trailers文件夹等
# 修改目标资源路径 以及 忽略的文件夹
VCBStudio_dir=/path/to/VCBStudio_dir
ignore_dir=ignore_dir
cd $VCBStudio_dir
# \[ 转义，用来匹配[
# {} 代表当前文件
# \ 代表结束 -exec 选项
# ./ 表示当前路径
# * 匹配文件和目录 */ 匹配目录
# 将目录下所有文件
for dir in */ ;do
    if [ "$(basename "$dir")" != "$ignore_dir" ]; then
        # 在每个找到的目录中创建 Interviews Trailers Other 文件夹
        # 将剧集文件放入Season文件夹
        mkdir -p "$dir/Season" "$dir/Interviews" "$dir/Trailers" "$dir/Other"
        find $dir/ -mindepth 1 -maxdepth 1 -type f -exec mv {} "$dir/Season/" \;
        # 如果SPs目录存在则
        if [ -d "$dir/SPs" ]; then
            # 识别特典名称中的关键词[IV],放入Interviews文件夹
            find $dir/SPs/ -type f -name "*\[IV\]*" -exec mv {} $dir/Interviews/ \;
            # 识别特典名称中的关键词[Preview、Web Preview、CM、SPOT、PV、Trailer、Teaser],放入Trailers文件夹
            # 有些关键词后面没有数字，有些关键词后面有数字，例如[Preview01]，有些数字与字母之间还有空格，例如[Preview 01]
            # 有些关键词是大写，如Web和WEB
            find $dir/SPs/ -type f -name "*\[Menu*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[Preview*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[Web Preview*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[WEB Preview*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[CM*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[SPOT*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[PV*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[Game PV*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[Trailer*\]*" -exec mv {} $dir/Trailers/ \;
            find $dir/SPs/ -type f -name "*\[Teaser*\]*" -exec mv {} $dir/Trailers/ \;
            # 识别特典名称中的关键词[NCOP、NCED],放入Other文件夹
            find $dir/SPs/ -type f -name "*\[NCOP*\]*" -exec mv {} $dir/Other/ \;
            find $dir/SPs/ -type f -name "*\[NCED*\]*" -exec mv {} $dir/Other/ \;
            #检测"$dir/SPs"目录中是否还有剩余文件，如果有则输出剩余文件个数
            if [ "$(ls -A "$dir/SPs")" ]; then
                echo "[warning!]There are $(ls -A "$dir/SPs" | wc -l) files left in $dir/SPs"
            else
                # 删除空目录
                rmdir "$dir/SPs"
                echo "$dir done!"
            fi
        fi
    fi
done
