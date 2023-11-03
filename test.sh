#!/bin/bash
#author: ferrum
#version: v1
#date: 2023-11-02
#编写内容：测试内容

# 定义颜色变量
RED='\e[1;31m' # 红
GREEN='\e[1;32m' # 绿
YELLOW='\e[1;33m' # 黄
BLUE='\e[1;34m' # 蓝
PINK='\e[1;35m' # 粉红
RES='\e[0m' # 清除颜色

INFO_LOG_PREFIX=$(date +"%Y-%m-%d %H:%M:%S")" [info] [shell] "
WARN_LOG_PREFIX=${YELLOW}$(date +"%Y-%m-%d %H:%M:%S")" [warn] [shell] "
ERROR_LOG_PREFIX=${RED}$(date +"%Y-%m-%d %H:%M:%S")" [error] [shell] "

info_print() {
    echo -e $INFO_LOG_PREFIX $1 ${RES}
}

warn_print() {
    echo -e $WARN_LOG_PREFIX $1 ${RES}
}

error_print() {
    echo -e $ERROR_LOG_PREFIX $1 ${RES}
}

check_ok() {
        if [ $? -ne 0 ]; then
                error_print "$1 步骤出现问题！"
                exit 1
        fi
}

test_input() {
    read -p "${INFO_LOG_PREFIX}是否启用mainland版本（默认为stable版本）:" choice
    if [ $choice = Y ] || [ $choice = y ]; then 
        echo "同意"
    else
        echo "不同意"
    fi
}

test_time() {
    echo $(date +"%Y-%m-%d %H:%M:%S")
}

test_echo_log() {
   info_print "测试INFO打印"
   warn_print "测试WARN打印"
   error_print "测试ERROR打印"
    # echo -e $WARN_LOG_PREFIX "测试WARN打印"
    # echo -e $ERROR_LOG_PREFIX "测试ERROR打印"
}

test_find() {
    #service_path=$(find / -maxdepth 10 -name "nginx.service" -type f)
    #echo $INFO_LOG_PREFIX $service_path
    test_path=$(find /opt -name "a.sh" -type f)
    #echo $test_path
    if [ "$test_path" ]; then
        echo $INFO_LOG_PREFIX "文件存在"
    else
        echo $INFO_LOG_PREFIX "文件不存在"
    fi
}

test_getVersion() {
    curl -s https://nginx.org/download/ | grep -oP '(?<=nginx-)\d+\.\d+\.\d+' | sort -t. -k1,1nr -k2,2nr -k3,3nr | uniq > /tmp/nginx-version.txt
    head -n 10 /tmp/nginx-version.txt
    while :
    do
        read -p "${INFO_LOG_PREFIX}请选择安装版本：" version
        echo $version
        if grep -q $version "/tmp/nginx-version.txt"; then
            echo "版本存在"
            break
        else
            echo "版本不存在"
        fi
    done
    
}

#test_input
#test_time
test_echo_log
check_ok "测试打印"
#test_find
#test_getVersion
