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
#VCBStudio_dir=/path/to/VCBStudio_dir
# 定位待处理目录和忽略的目录
VCBStudio_dir=/path/to/VCBStudio_dir
ignore_dirs=("ignore_dir1" "ignore_dir2")
# 是否重命名 以及 是否重命名SPs，默认不重命名，不对SPs进行重命名
ifRename=0
ifRenameSPs=0
ignore_paths=()
for ignore_dir in "${ignore_dirs[@]}"; do
    ignore_paths+=(-path "./$ignore_dir" -prune -o)
done
cd $VCBStudio_dir
# \[ 转义，用来匹配[
# {} 代表当前文件
# \ 代表结束 -exec 选项
# ./ 表示当前路径
# * 匹配文件和目录 */ 匹配目录
# 将目录下所有文件
# -print 只打印 -o 后面匹配的路径

# 整理文件位置
find . "${ignore_paths[@]}" -type d -iname 'SPs' -print | while IFS= read -r sp_dir; do
    dir=${sp_dir%/*}
    # 在每个找到的目录中创建 Interviews Trailers Other 文件夹
    mkdir -p "$dir/Season" "$dir/Interviews" "$dir/Trailers" "$dir/Other"
    # 将剧集文件放入Season文件夹
    find "$dir/" -mindepth 1 -maxdepth 1 -type f -exec mv {} "$dir/Season/" \;
    # 如果SPs目录存在则
    if [ -d "$dir/SPs" ]; then
        # 识别特典名称中的关键词[IV],放入Interviews文件夹
        find "$dir/SPs/" -type f -iname "*\[IV*\]*" -exec mv {} "$dir/Interviews/" \;
        # 识别特典名称中的关键词[Preview、Web Preview、CM、SPOT、PV、Trailer、Teaser],放入Trailers文件夹
        # 有些关键词后面没有数字，有些关键词后面有数字，例如[Preview01]，有些数字与字母之间还有空格，例如[Preview 01]
        # 有些关键词是大写，如Web和WEB
        find "$dir/SPs/" -type f -iname "*\[Menu*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[Preview*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[Web Preview*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[CM*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[SPOT*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[PV*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[Game PV*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[Trailer*\]*" -exec mv {} "$dir/Trailers/" \;
        find "$dir/SPs/" -type f -iname "*\[Teaser*\]*" -exec mv {} "$dir/Trailers/" \;
        # 识别特典名称中的关键词[NCOP、NCED],放入Other文件夹
        # 放弃识别Other了，剩下的全放到Other里
        find "$dir/SPs/" -type f -exec mv {} "$dir/Other/" \;
        #检测"$dir/SPs"目录中是否还有剩余文件，如果有则输出剩余文件个数
        if [ "$(ls -A "$dir/SPs")" ]; then
            echo "[warning!]There are $(ls -A "$dir/SPs" | wc -l) files left in $dir/SPs"
        else
            # 删除空目录
            rmdir "$dir/SPs"
            echo "$dir done!"
        fi
    fi
done
# 文件夹重命名，去除首部中括号
# 有些资源包含HDR版本，因此仅去除首部中括号
if [ $ifRename -eq 1 ];then
    find . -name "\[*\]*\[*\]*" -type d -print | while IFS= read -r item; do
        # 处理目录
        # 获取目录名（去掉路径）
        dirname=$(basename "$item")
        # 形如 [xxx] aa [xxx], 提取中间部分
        # newname=$(echo "$dirname" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]$/\1/p')
        # tmp1=${dirname#*]}
        # tmp2=${tmp1#*[}
        # typename=${tmp2%%]*}
        newname=${dirname#*]}
        newpath=$(dirname "$item")/"$newname"
        # 执行重命名操作
        mv "$item" "$newpath"
        echo "Renamed dir $item to $newpath"
    done
    find . -name "\[*\]*" -type d -print | while IFS= read -r item; do
        # 处理目录
        # 获取目录名（去掉路径）
        dirname=$(basename "$item")
        # 形如 [xxx] aa [xxx], 提取中间部分
        # newname=$(echo "$dirname" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]$/\1/p')
        # tmp1=${dirname#*]}
        # tmp2=${tmp1#*[}
        # typename=${tmp2%%]*}
        newname=${dirname#*]}
        newpath=$(dirname "$item")/"$newname"
        # 执行重命名操作
        mv "$item" "$newpath"
        echo "Renamed dir $item to $newpath"
    done
    # 重命名文件
    # 文件重命名，去除首尾中括号，但是要保留有关集数的信息
    # 默认不整理SPs，如果需要整理，则设置ifRenameSPs为1
    if [ $ifRenameSPs -eq 1 ]; then
        find . "${ignore_paths[@]}" -type d -iname 'Season*' -print | while IFS= read -r season_dir; do
            find "$season_dir/" -type f -name "\[*\]*\[*\]*" -print | while IFS= read -r item; do
                # 处理文件
                # 获取文件名（去掉路径）
                filename=$(basename "$item")
                # 形如 [xxx] aa [xxx].extension, 提取中间部分，文件类型和扩展名
                newname=$(echo "$filename" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]\.(.*)$/\1/p')
                tmp1=${filename#*]}
                tmp2=${tmp1#*[}
                typename=${tmp2%%]*}
                extension=$(echo "$filename" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]\.(.*)$/\2/p')
                newpath=$(dirname "$item")/"$newname [$typename].$extension"
                # 执行重命名操作
                mv "$item" "$newpath"
            done
        done
    else
        find . -name "\[*\]*\[*\]*" -print | while IFS= read -r item; do
            filename=$(basename "$item")
            # 形如 [xxx] aa [xxx].extension, 提取中间部分，文件类型和扩展名
            newname=$(echo "$filename" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]\.(.*)$/\1/p')
            tmp1=${filename#*]}
            tmp2=${tmp1#*[}
            typename=${tmp2%%]*}
            extension=$(echo "$filename" | sed -r -n 's/^\[.*?\]\s+(.*)\s+\[.*?\]\.(.*)$/\2/p')
            newpath=$(dirname "$item")/"$newname [$typename].$extension"
            # 执行重命名操作
            mv "$item" "$newpath"
        done
    fi
fi
