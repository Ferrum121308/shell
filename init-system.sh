#!/bin/bash
#author: ferrum
#version: v1
#date: 2023-10-21
#编写内容：初始化系统

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

package_install() {
        yum update -y
        yum install -y yum-utils
        cat >/tmp/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
        sudo mv /tmp/nginx.repo /etc/yum.repos.d/nginx.repo

        read -p "${INFO_LOG_PREFIX}是否启用mainland版本（默认为stable版本）:" choice
        if [ $choice = Y ] || [ $choice = y ]; then
                sudo yum-config-manager --enable nginx-mainline
        else
                info_print "不启用mainland版本"
        fi
        warn_print "前期依赖安装完毕"
        sudo yum install -y nginx
        # 从服务器下载注意事项
        # curl -O
        # 手写注意事项
        cat >/NOTE.md <<EOF
注意：
1.主要配置地址：/etc/nginx/nginx.conf
2.配置文件存放地址：/etc/nginx/conf.d
Nginx配置时，新增配置文件即可，主要配置中已经包含了该地址
3.页面存放地址：/usr/share/nginx/html
其他页面存放在该文件夹下即可
4.包安装方式，systemd已经管理了Nginx服务，直接使用命令即可启动
EOF
}

source_install() {
        yum update -y
        yum install -y gcc zlib zlib-devel pcre-devel openssl openssl-devel
        # 获取可安装版本
        curl -s https://nginx.org/download/ | grep -oP '(?<=nginx-)\d+\.\d+\.\d+' | sort -t. -k1,1nr -k2,2nr -k3,3nr | uniq >/tmp/nginx-version.txt
        # 选择安装版本
        head -n 10 /tmp/nginx-version.txt
        while :
        do
                read -p "${INFO_LOG_PREFIX}请选择安装版本：" version
                if grep -q $version "/tmp/nginx-version.txt"; then
                        # 删除版本文件
                        rm -rf /tmp/nginx-version.txt
                        mkdir /download
                        # 下载文件
                        curl -s -o /download/nginx.tar.gz http://nginx.org/download/nginx-$version.tar.gz
                        tar -zxvf nginx.tar.gz
                        break
                else
                        error_print "版本不存在，请重新输入！"
                fi
        done

}

# 安装Nginx
install_nginx() {
        info_print "开始安装Nginx"
        info_print "可供选择的安装方式有："
        info_print "1--官网推荐的安装包模式"
        info_print "2--源码编译模式"
        info_print "0--跳过Nginx安装"
        read -p "请选择安装方式：" way
        case $way in
        1)
                warn_print "您选择了安装包模式"
                package_install
                break
                ;;
        2)
                warn_print "您选择了源码模式"
                source_install
                break
                ;;
        0)
                warn_print "您选择了跳过Nginx安装"
                break
                ;;
        *)
                error_print "选择方式错误"
                install_nginx
                ;;
        esac
}

start_nginx() {
        service_path=$(find / -maxdepth 10 -name "nginx.service" -type f)
        if [ "$service_path" ]; then
                warn_print "启动服务"
                systemctl start nginx
                systemctl enable nginx
                systemctl status nginx
        else
                warn_print "编写启动文件"
                # 手写nginx.service文件并启动
        fi
        warn_print "Nginx 启动成功"
}

warn_print "开始初始化该系统"
install_nginx
start_nginx
warn_print "Nginx部分结束"
