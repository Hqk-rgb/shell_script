#!/bin/bash

read -p "数据库用户名：" username
read -sp "数据库密码：" password

# 源码安装方式先查询是否配置了环境变量
if grep -q '^PATH=.*:/usr/local/mysql/bin' /etc/profile ;then
   echo "环境变量已经配置，开始全量备份..."
else
   echo "未配置环境变量，开始配置mysql环境变量..."
   sed -i "/^PATH=/ s|$|:/usr/local/mysql/bin|" "/etc/profile"
   #echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
   source /etc/profile
   echo "成功配置环境变量！"
fi

backup_dir="/usr/local/mysql/backup"
mkdir -p "$backup_dir"
mysqldump -u"${username}" -p"${password}" --all-databases > "$backup_dir/all.sql"

if [[ $? -eq 0 ]]; then
    echo "全量备份完成！文件路径：$backup_dir/all.sql"
else
    echo "备份失败，请检查用户名、密码和数据库配置。"
fi
