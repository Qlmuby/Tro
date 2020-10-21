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

docker_install(){
	$systemPackage update -y
	$systemPackage install curl -y
	curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
	green "================================="
	blue "     请设置数据库密码"
	green "================================="
	read passwd
	docker run --name trojan-mariadb --restart=always -p 3306:3306 -v /home/mariadb:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$passwd -e MYSQL_ROOT_HOST=% -e MYSQL_DATABASE=trojan -d mariadb:10.2
	docker run -it -d --name trojan --net=host --restart=always --privileged jrohy/trojan init
	wget -N --no-check-certificate "https://raw.githubusercontent.com/qlmuby/Tro/master/web.sh" && chmod +x web.sh && ./web.sh
}

into_docker(){
	green "================================="
	blue "     Ctrl+P+Q 退出容器"
	blue "     初始化菜单请输入'trojan'"
	green "================================="
	docker exec -it trojan bash
}

web_deploy(){
	$systemPackage update -y
	$systemPackage -y install nginx unzip curl wget
	systemctl enable nginx
	systemctl stop nginx
if test -s /etc/nginx/nginx.conf; then
	rm -rf /etc/nginx/nginx.conf
  wget -P /etc/nginx https://raw.githubusercontent.com/Qlmuby/Tro/master/nginx.conf
	green "================================="
	blue "     请输入需要绑定的域名"
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
	green "================================="
	blue "     请输入伪装网站版本号"
	green "================================="
	read version
	wget https://github.com/Qlmuby/Tro/releases/download/$version/web.zip
	unzip web.zip
	
  systemctl restart nginx
  green " "
  green " "
  green " "
	green "=================================================================="
	 blue "  伪装站点目录 /usr/share/nginx/html "
	 blue "  伪装网站地址 http://$your_domain "
	green "=================================================================="
else
	green "==============================="
	  red "     Nginx未正确安装 请重试"
	green "==============================="
	sleep 2s
	exit 1
fi
}

v2ray_ui(){
    $systemPackage install -y curl
		bash <(curl -Ls https://blog.sprov.xyz/v2-ui.sh)
}

bbr_sh(){
    $systemPackage install -y wget
    wget -N "https://github.000060000.xyz/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

rm_docker(){
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
    docker rmi $(docker images -q)
	wget -N --no-check-certificate "https://raw.githubusercontent.com/qlmuby/Tro/master/web.sh" && chmod +x web.sh && ./web.sh
}

start_menu(){
  clear
	green "=========================================================="
      red " V2ray Trojan 综合管理脚本（Qlmuby）"
	green "=========================================================="
	  red " 温馨提示：推荐使用Debian Ubuntu系统"
	green "=========================================================="
	 blue " 1. 脚本安装 BBRPlus 加速"
     blue " 2. 宿主机部署 Web 伪装站点"
     blue " 3. 宿主机安装 V2-UI 管理面板"
     blue " 4. 一键进入Trojan Docker容器"
     blue " 5. 一键安装Docker版Trojan-Web"
     blue " 6. 一键卸载所有Docker容器和镜像"
     blue " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
		bbr_sh
		;;
		2)
		web_deploy
		;;
		3)
		v2ray_ui
		;;
		4)
		into_docker
		;;
		5)
		docker_install
		;;
		6)
		rm_docker
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
