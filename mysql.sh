#!/bin/bash
# 安装mysql8，并配置主从复制（云服务器版）
read -p "请输入mysql的版本（5/8）：" VER

# 下载安装
if [ $VER -eq 5 ]; then
    wget http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
    yum -y install mysql57-community-release-el7-10.noarch.rpm
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    yum -y install mysql-community-server
    yum -y remove mysql57-community-release-el7-10.noarch
fi

if [ $VER -eq 8 ]; then
    wget http://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
    yum -y install mysql80-community-release-el7-3.noarch.rpm
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
    yum -y install mysql-community-server
    yum -y remove mysql80-community-release-el7-3.noarch.rpm
fi

# 权限设置
systemctl stop firewalld
systemctl disable firewalld

# 服务启动
systemctl start mysqld.service
systemctl enable mysqld.service

# ROOT密码更改
OPWD=`grep "password" /var/log/mysqld.log | awk -v FS=":" '{print $4}' | awk '{print $1}' | sed -n '1p'`
read -p "请输入ROOT的新密码：" NPWD
yum -y install expect &> /dev/null
expect << EOF
spawn mysqladmin -u root -p password
expect {
    "Enter password:"       {send "$OPWD\n"; exp_continue}
    "New password:"         {send "$NPWD\n"; exp_continue}
    "Confirm new password:" {send "$NPWD\n"; exp_continue}
}
EOF


# 新建用户
read -p "是否新建用户（Y/N）：" USER

if [ $USER = Y ]; then

read -p "请输入ROOT用户的密码：" RPWD
read -p "请输入新建的用户的名称：" NUSER
read -p "请输入新建的用户的密码：" NPWD

mysql -uroot -p$RPWD -e "create user '$NUSER'@'localhost' identified by '$NPWD';"
mysql -uroot -p$RPWD -e "create user '$NUSER'@'%' identified by '$NPWD';"
mysql -uroot -p$RPWD -e "flush privileges;"
mysql -uroot -p$RPWD -e "grant all privileges on *.* to '$NUSER'@'localhost' identified by '$NPWD';"
mysql -uroot -p$RPWD -e "grant all privileges on *.* to '$NUSER'@'%' identified by '$NPWD';"
mysql -uroot -p$RPWD -e "flush privileges;"

fi


# 主从复制
read -p "是否部署主从复制（Y/N）：" MS

if [ $MS = Y ]; then
    read -p "请输入部署的数据库的类型（MASTER/SLAVE）：" TYPE
fi

if [ $MS = Y ] && [ $TYPE = MASTER ]; then

    yum -y install ntp
    ntpdate ntp.aliyun.com
    sed -i '$a 00 00 * * * root /usr/sbin/ntpdate ntp.aliyun.com' /etc/crontab

    read -p "请输入主数据库的唯一标识（server-id）：" ID
    sed -i '$a server-id='"$ID"'' /etc/my.cnf
    sed -i '$a log-slave-updates=true' /etc/my.cnf
    sed -i '$a log-bin=master-bin' /etc/my.cnf

    systemctl restart mysqld.service

    read -p "请输入ROOT用户的密码：" RPWD
    read -p "请输入主从复制的用户的名称：" MSUSER
    read -p "请输入主从复制的用户的密码：" MSPWD
    read -p "请输入从数据库的IP地址：" SIP
    mysql -uroot -p$RPWD -e "GRANT REPLICATION SLAVE ON *.* TO '$MSUSER'@'$SIP' IDENTIFIED BY '$MSPWD';"
    mysql -uroot -p$RPWD -e "flush privileges;"
    mysql -uroot -p$RPWD -e "show master status;"

fi

if [ $MS = Y ] && [ $TYPE = SLAVE ]; then

    yum -y install ntp
    ntpdate ntp.aliyun.com
    sed -i '$a 00 00 * * * root /usr/sbin/ntpdate ntp.aliyun.com' /etc/crontab

    read -p "请输入从数据库的唯一标识（server-id）：" ID
    sed -i '$a server-id='"$ID"'' /etc/my.cnf
    sed -i '$a log-bin=mysql-bin' /etc/my.cnf
    sed -i '$a relay-log=relay-log-bin' /etc/my.cnf
    sed -i '$a relay-log-index=slave-relay-bin.index' /etc/my.cnf

    systemctl restart mysqld.service

    read -p "请输入ROOT用户的密码：" RPWD
    read -p "请输入主从复制的用户的名称：" MSUSER
    read -p "请输入主从复制的用户的密码：" MSPWD
    read -p "请输入主数据库的IP地址：" MIP
    read -p "请输入主数据库的二进制日志的文件名称：" MBLOG
    read -p "请输入主数据库的日志位置：" POS
    mysql -uroot -p$RPWD -e "change master to master_host='$MIP',master_user='$MSUSER',master_password='$MSPWD',master_log_file='$MBLOG',master_log_pos=$POS;"

    mysql -uroot -p$RPWD -e "start slave;"
    mysql -uroot -p$RPWD -e "show slave status\G"

fi
