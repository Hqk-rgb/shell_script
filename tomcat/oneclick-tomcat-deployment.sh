#!/bin/bash
 
# 定义颜色和样式
lvse='\033[1;32m'  # 绿色加粗
NC='\033[0m'       # 重置颜色
 
 
# 检查安装包是否存在
if [[ ! -f /root/jdk-8u221-linux-x64.tar.gz || ! -f /root/apache-tomcat-9.0.98.tar.gz ]]; then
    echo "\033[31;1m请上传安装包\033[0m"
else
    echo -e "\033[1;32m安装包存在\033[0m" # 提示红色字体加粗
fi
 
# 停止防火墙
if systemctl stop firewalld; then
    echo -e "\033[1;32m成功停止防火墙\033[0m"
else
    echo -e "\033[1;31m配置防火墙错误，停止执行脚本\033[0m"
    exit 1
fi
 
# 禁用防火墙
if systemctl disable firewalld; then
    echo -e "\033[1;32m成功禁用防火墙\033[0m"
else
    echo -e "\033[1;31m配置防火墙错误，停止执行脚本\033[0m"
    exit 1
fi
 
# 检查 SELinux 状态
if sestatus | grep -q "disabled"; then
    echo -e "${lvse}SELinux 已禁用!"
else
    # 尝试禁用 SELinux
    if setenforce 0; then
        echo -e "${lvse}成功禁用 SELinux"
    else
        echo -e "\033[1;31m禁用 SELinux 失败！\033[0m"
        exit 1
    fi
fi
 
#安装JDK
cd /root || exit 1  # 确保切换目录成功
mv /root/jdk-8u221-linux-x64.tar.gz /usr/local
cd /usr/local
tar -zxvf jdk-8u221-linux-x64.tar.gz
mv jdk1.8.0_221 jdk8
 
# 配置 JDK 环境变量
cat >> /etc/profile <<EOF
JAVA_HOME=/usr/local/jdk8
JRE_HOME=/usr/local/jdk8/jre
CLASS_PATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH
EOF
source /etc/profile

# 检查 JDK 是否安装成功
if java -version &> /dev/null; then
    echo -e "${lvse}JDK 安装完成!"
else
    echo -e "\033[31;1m JDK 安装失败! \033[0m"
    exit 1
fi
 
# 安装并启动 Tomcat
cd /root || exit 1  # 确保切换目录成功
mv /root/apache-tomcat-9.0.98.tar.gz /usr/local
cd /usr/local
tar -zxvf apache-tomcat-9.0.98.tar.gz &> /dev/null
mv apache-tomcat-9.0.98 tomcat9

# 配置 tomcat 环境变量
cd /usr/local/tomcat9/bin || exit 1
cat >> catalina.sh <<EOF
JAVA_OPTS="-Xms512m -Xmx1024m -Xss1024K -XX:PermSize=512m -XX:MaxPermSize=1024m"
export TOMCAT_HOME=/usr/local/tomcat9
export CATALINA_HOME=/usr/local/tomcat9
export JRE_HOME=/usr/local/jdk8/jre
export JAVA_HOME=/usr/local/jdk8
EOF
echo -e "${lvse} Tomcat环境变量配置完成！"
 
# 启动 Tomcat 
/usr/local/tomcat9/bin/startup.sh > /dev/null 2>&1
 
# 检查 Tomcat 是否启动成功
if [ $? -eq 0 ]; then
    echo -e "${lvse}Tomcat 安装完成！"
else
    echo -e "\033[31;1m Tomcat 启动失败! \033[0m"
    exit 1
fi
 
# 获取有效的 IP 地址
IP=$(ip -o -f inet addr show | awk '/ens33|eth0|ens160/{print $4}' | cut -d'/' -f1 | head -n 1)
 
# 设置端口
PORT=8080
 
# 输出提示信息
if [ -n "$IP" ]; then
    echo -e "${lvse}登录浏览器访问：http://$IP:$PORT"
else
    echo -e "\033[31;1m未找到有效的网络 IP 地址! \033[0m" #报错提示红色加粗
fi