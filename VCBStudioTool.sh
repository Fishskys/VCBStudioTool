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
# 定位待处理目录和忽略的目录
source ./usr.conf

ignore_paths=()
for ignore_dir in "${ignore_dirs[@]}"; do
    ignore_paths+=(-path "./$ignore_dir" -prune -o)
done

# 是否启用代理
if [ $ifproxy -eq 1 ];then
    export http_proxy=$http_proxy_address
    export https_proxy=$https_proxy_address
fi

function getName(){
    local query=$(echo -n "$1" | jq -sRr @uri)
    response=$(curl --request GET \
     --url "https://api.themoviedb.org/3/search/multi?query=${query}&include_adult=${adult}&language=${language}&page=1" \
     --header "Authorization: Bearer ${tmdb_api_key}" \
     --header 'accept: application/json')
    if [ $? -eq 0 ]; then
        mediaType=$(echo "$response" | jq -r '.results[0].media_type')
        if [ "$mediaType" == "movie" ]; then
            title=$(echo "$response" | jq -r '.results[0].title')
            echo "$title"
        elif [ "$mediaType" == "tv" ]; then
            name=$(echo "$response" | jq -r '.results[0].name')
            echo "$name"
        fi
    else
        echo "在搜索${1}时,API 请求失败"
        return 1
    fi
}


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
    find "$dir/" -mindepth 1 -maxdepth 1 -type f -iname "*\[Fonts*\]*" -exec mv {} "$dir/Other/" \;
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

# 处理目录
# 总文件夹一般只有首部有中括号，季度文件夹首尾皆有中括号
# 有些资源包含HDR版本，体现在尾部中括号中，因此仅去除首部中括号
if [ $ifRenameDirs -eq 1 ];then
    # [Mabors-Sub&Kamigami&KTXP&VCB-Studio] Saenai Heroine no Sodatekata Fine [Ma10p_1080p]
    find . "${ignore_paths[@]}" -type d -name "\[*\]*\[*\]*" -print | while IFS= read -r item; do
        # 获取目录名（去掉路径）
        dirname=$(basename "$item")
        # temp: xx []
        temp=${dirname#*]}
        # originalName: xx
        originalName=${temp%%[*}
        typeName="[${temp#*[}"

        # 季度文件夹使用TMDB搜索得到的名字一般相同，极易覆盖，所以不再使用TMDB重命名
        # if [ $ifTMDB -eq 1 ];then
        #     newname=$(getName "$originalName")
        #     if [ $? -eq 0 ]; then
        #         newpath=$(dirname "$item")/"$newname $typeName"
        #     else
        #         newpath=$(dirname "$item")/"$temp"
        #     fi
        # else
        #     newpath=$(dirname "$item")/"$temp"
        # fi

        newpath=$(dirname "$item")/"$temp"
        # 执行重命名操作
        mv "$item" "$newpath"
        echo "Renamed dir $item to $newpath"
    done
    find . "${ignore_paths[@]}" -type d -name "\[*\]*" -print | while IFS= read -r item; do
        # 获取目录名（去掉路径）
        dirname=$(basename "$item")
        # originalName: xx
        originalName=${dirname#*]}
        if [ $ifTMDB -eq 1 ];then
            newname=$(getName "$originalName")
            if [ $? -eq 0 ]; then
                newpath=$(dirname "$item")/"$newname"
            else
                newpath=$(dirname "$item")/"$originalName"
            fi
        else
            newpath=$(dirname "$item")/"$originalName"
        fi
        # 执行重命名操作
        mv "$item" "$newpath"
        echo "Renamed dir $item to $newpath"
    done
fi


# 重命名剧集文件
# 文件重命名，去除首尾中括号，但是要保留有关集数的信息
if [ $ifRenameFiles -eq 1 ]; then
    find . "${ignore_paths[@]}" -type d -iname 'Season*' -print | while IFS= read -r season_dir; do
        find "$season_dir/" -type f -name "\[*\]*\[*\]*" -print | while IFS= read -r item; do
            # 处理文件
            # 获取文件名（去掉路径）
            # 一个典型的剧集名字：[Airota&VCB-Studio] Chuunibyou demo Koi ga Shitai! [01][Hi10p_1080p][x264_flac].mka
            filename=$(basename "$item")
            # tmp1: Chuunibyou demo Koi ga Shitai! [01][Hi10p_1080p][x264_flac].mka
            # tmp2: 01][Hi10p_1080p][x264_flac].mka
            # tmp3: 01 或者 lite
            # originalName: Chuunibyou demo Koi ga Shitai!
            # episode: E01
            tmp1=${filename#*]}
            tmp2=${tmp1#*[}
            originalName=${tmp1%%[*}
            tmp3=${tmp2%%]*}

            # 部分剧集存在 lite，需要特殊处理
            if [[ $tmp3 =~ ^[0-9]+$ ]]; then
                episode="E$tmp3"
            else
                episode="[$tmp3]"
            fi

            extension=${filename##*]}
            if [ $ifTMDB -eq 1 ];then
                newname=$(getName "$originalName")
                if [ $? -eq 0 ]; then
                    newpath=$(dirname "$item")/"$newname $episode$extension"
                else
                    newpath=$(dirname "$item")/"$originalName $episode$extension"
                fi
            else
                newpath=$(dirname "$item")/"$originalName $episode$extension"
            fi
            # 执行重命名操作
            mv "$item" "$newpath"
        done
    done
fi

# 重命名SPs文件
# 仅去除首部中括号，[xxx] xxx [xxx]* --> xxx [xxx]*
if [ $ifRenameSPs -eq 1 ]; then
    find . "${ignore_paths[@]}" -type d \( -name 'Interviews' -o -name 'Trailers' \) -print | while IFS= read -r SPs_dir; do
        find "$SPs_dir/" -type f -name "\[*\]*\[*\]*" -print | while IFS= read -r item; do

            filename=$(basename "$item")
            newname=${filename#*]}
            newpath=$(dirname "$item")/"$newname"

            mv "$item" "$newpath"
        done
    done
fi

unset  http_proxy
unset  https_proxy
