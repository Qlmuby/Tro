#!/bin/bash
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

if [[ -f /etc/redhat-release ]]; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
    systempwd="/lib/systemd/system/"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
    systemPackage="yum"
    systempwd="/usr/lib/systemd/system/"
fi

change_panel(){
if test -s /etc/systemd/system/trojan-web.service; then
	green " "
	green " "
	green "================================="
	 blue "  检测到Trojan面板服务，开始配置"
	green "================================="
	sleep 2s
	$systemPackage update -y
	$systemPackage -y install nginx unzip curl wget
	systemctl enable nginx
	systemctl stop nginx
if test -s /etc/nginx/nginx.conf; then
	rm -rf /etc/nginx/nginx.conf
  wget -P /etc/nginx https://raw.githubusercontent.com/Qlmuby/Tro/master/nginx.conf
	green "================================="
	blue "     请输入Trojan绑定的域名"
	green "================================="
	read your_domain
  sed -i "s/localhost/$your_domain/;" /etc/nginx/nginx.conf
	green " "
	green "================================="
	 blue "    开始下载伪装站点源码并部署"
	green "================================="
	sleep 2s
	rm -rf /usr/share/nginx/html/*
	cd /usr/share/nginx/html/
	wget https://github.com/Qlmuby/Tro/releases/download/2.0/web.zip
	unzip web.zip
	green " "
	green "================================="
	blue "       开始配置trojan-web"
	green "================================="
	sleep 2s
  sed -i '/ExecStart/s/trojan web -p 2011/trojan web/g' /etc/systemd/system/trojan-web.service
  sed -i '/ExecStart/s/trojan web/trojan web -p 2011/g' /etc/systemd/system/trojan-web.service
  systemctl daemon-reload
  systemctl restart trojan-web
  systemctl restart nginx
  green " "
  green " "
  green " "
	green "=================================================================="
	 blue "  伪装站点目录 /usr/share/nginx/html "
	 blue "  面板管理地址 http://$your_domain:2011 "
	green "=================================================================="
else
	green "==============================="
	  red "     Nginx未正确安装 请重试"
	green "==============================="
	sleep 2s
	exit 1
fi
else
	green "==============================="
	  red "    未检测到Trojan面板服务"
	green "==============================="
	sleep 2s
	exit 1
fi
}

bbr_boost_sh(){
    $systemPackage install -y wget
    wget -N --no-check-certificate -q -O tcp.sh "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && bash tcp.sh
}

trojan_install(){
    $systemPackage install -y curl
		source <(curl -sL https://git.io/trojan-install)
}

start_menu(){
  clear
	green "=========================================================="
   blue " 简介：Trojan 多用户管理面板"
	green "=========================================================="
	  red " 运行本脚本之前请确认已经安装 Trojan 多用户管理面板"
	green "=========================================================="
	 blue " 1. 安装 Trojan 多用户管理面板"
   blue " 2. 更改 Trojan 面板端口并设置伪装站点"
   blue " 3. 安装 BBRPlus4 合一加速"
   blue " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
		trojan_install
		;;
		2)
		change_panel
		;;
		3)
		bbr_boost_sh
		;;
		0)
		exit 0
		;;
		*)
	clear
	echo "请输入正确数字"
	sleep 2s
	start_menu
	;;
    esac
}

start_menu
