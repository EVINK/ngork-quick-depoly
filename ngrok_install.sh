#!/bin/bash
# -*- coding: UTF-8 -*-
# 获取当前脚本执行路径
SELFPATH=$(
    cd "$(dirname .)"
    pwd
)
GOOS=$(go env | grep GOOS | awk -F\" '{print $2}')
GOARCH=$(go env | grep GOARCH | awk -F\" '{print $2}')
echo '请输入一个域名 / Please Input A Domain: '
read DOMAIN

# 安装go
install_go() {
    cd $SELFPATH
    uninstall_go
    # 动态链接库，用于下面的判断条件生效
    ldconfig
    # 判断操作系统位数下载不同的安装包
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]; then
        # 判断文件是否已经存在
        if [ ! -d $SELFPATH/go1.4.2.linux-amd64.tar.gz ]; then
            # wget http://www.golangtc.com/static/go/1.4.2/go1.4.2.linux-amd64.tar.gz
            wget https://dl.google.com/go/go1.12.4.linux-amd64.tar.gz
        fi
        tar zxvf go1.12.4.linux-amd64.tar.gz
    else
        if [ ! -d $SELFPATH/go1.4.2.linux-386.tar.gz ]; then
            wget http://www.golangtc.com/static/go/1.4.2/go1.4.2.linux-386.tar.gz
        fi
        tar zxvf go1.4.2.linux-386.tar.gz
    fi
    mv go /usr/local/
    ln -s /usr/local/go/bin/* /usr/bin/
}

# 卸载go
uninstall_go() {
    rm -rf /usr/local/go
    rm -rf /usr/bin/go
    rm -rf /usr/bin/godoc
    rm -rf /usr/bin/gofmt
}

# 安装ngrok
install_ngrok() {
    uninstall_ngrok
    cd /usr/local
    if [ ! -d /usr/local/ngrok.zip ]; then
        cd /usr/local/
        wget http://cdn.evink.cn/ngrok.zip
    fi
    unzip ngrok.zip
    export GOPATH=/usr/local/ngrok/
    export NGROK_DOMAIN=$DOMAIN
    cd ngrok
    openssl genrsa -out rootCA.key 2048
    openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -subj "/CN=$NGROK_DOMAIN" -out server.csr
    openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 5000
    cp rootCA.pem assets/client/tls/ngrokroot.crt
    cp server.crt assets/server/tls/snakeoil.crt
    cp server.key assets/server/tls/snakeoil.key
    # 替换下载源地址
    sed -i 's#code.google.com/p/log4go#github.com/keepeye/log4go#' /usr/local/ngrok/src/ngrok/log/logger.go
    cd /usr/local/go/src
    GOOS=$GOOS GOARCH=$GOARCH ./make.bash
    cd /usr/local/ngrok
    GOOS=$GOOS GOARCH=$GOARCH make release-server
    # /usr/local/ngrok/bin/ngrokd -domain=$NGROK_DOMAIN -httpAddr=":80"
}

# 卸载ngrok
uninstall_ngrok() {
    rm -rf /usr/local/ngrok
}

# 编译客户端
compile_client() {
    cd /usr/local/go/src
    GOOS=$1 GOARCH=$2 ./make.bash
    cd /usr/local/ngrok/
    GOOS=$1 GOARCH=$2 make release-client
}

# 生成客户端
client() {
    echo "1、Linux 32位"
    echo "2、Linux 64位"
    echo "3、Windows 32位"
    echo "4、Windows 64位"
    echo "5、Mac OS 32位"
    echo "6、Mac OS 64位"
    echo "7、Linux ARM"

    read num
    case "$num" in
    [1])
        compile_client linux 386
        ;;
    [2])
        compile_client linux amd64
        ;;
    [3])
        compile_client windows 386
        ;;
    [4])
        compile_client windows amd64
        ;;
    [5])
        compile_client darwin 386
        ;;
    [6])
        compile_client darwin amd64
        ;;
    [7])
        compile_client linux arm
        ;;
    *) echo "选择错误，退出" ;;
    esac

}

echo ""
echo "------------------------------------------------------------------------------"
echo "| 原作者 Original Author：Javen"
echo "| 修改 Author：EvinK@foxmail.com"
echo "| Success on Ubuntu 16.04 & 18.04 LTS "
echo "------------------------------------------------------------------------------"
echo
echo " 默认您已安装必要的依赖和工具(例如Git)"
echo
echo "------------------------"
echo "1、全新安装 / Fresh Install "
echo "2、安装go环境 / Install Go Environment"
echo "3、安装服务端 / Install Ngrokd Server"
echo "4、生成客户端 / Generate Ngrok Client"
echo "5、卸载 / Uninstall"
echo "------------------------"
read num
case "$num" in
[1])
    echo
    echo
    echo "全新安装将不会安装客户端， 请在安装成功后在此运行此脚本，选择选项4以安装客户端"
    echo "Fresh Install will not install ngrok client, please run this script with option 4 after Setp 1 is SUCCESS"
    echo
    echo
    install_go
    install_ngrok
    ;;
[2])
    install_go
    ;;
[3])
    install_ngrok
    ;;
[4])
    client
    ;;
[5])
    uninstall_go
    uninstall_ngrok
    ;;
[9])
    echo "#############################################"
    echo "#原作者：Javen"
    echo "#修改：EvinK@foxmail.com"
    echo "#创建ngrok.cfg文件并添加以下内容"
    echo server_addr: '"'$DOMAIN:4443'"'
    echo "trust_host_root_certs: false"
    echo "#############################################"
    echo "#############################################"
    echo "#Window启动脚本"
    echo "ngrok -config=ngrok.cfg -subdomain=你域名的前缀  本地映射的端口号"
    echo "ngrok -config=ngrok.cfg -subdomain=javen  80"
    echo "#############################################"
    echo "#############################################"
    echo "#Linux Mac 启动脚本"
    echo "./ngrok -config=./ngrok.cfg -subdomain=你域名的前缀  本地映射的端口号"
    echo "./ngrok -config=./ngrok.cfg -subdomain=javen  80"
    echo "#Linux Mac 后台启动脚本"
    echo "setsid ./ngrok -config=./ngrok.cfg -subdomain=javen 80"
    echo "#############################################"
    ;;
*) echo "" ;;
esac

echo
echo
echo
echo "Done!"
echo
echo
echo
