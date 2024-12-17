#!/bin/bash
read -p "数据库用户名：" mysql_user
read -sp "数据库密码：" mysql_password
echo

# 设置mysql的登录用户名和密码(根据实际情况填写)
mysql_port="3306"
#增量备份时复制mysql-bin.00000*的目标目录，提前手动创建这个目录
backup_dir=/usr/local/mysql/backup
#mysql的index文件路径（依据自己的）
binlog_dir=/var/lib/mysql
binlog_index=$binlog_dir/binlog.index
# 判断mysql实例是否正常运行
welcome_msg="start backup binlog, please wait..."
mysql_ps=`ps -ef |grep mysql |wc -l`
mysql_listen=`netstat -an |grep LISTEN |grep $mysql_port|wc -l`
if [ [$mysql_ps == 0] -o [$mysql_listen == 0] ]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S'): ERROR:MySQL is not running! backup stop!"
        exit
else
        echo "$(date +'%Y-%m-%d %H:%M:%S'): $welcome_msg"
fi
#这个是用于产生新的mysql-bin.00000*文件（mysqladmin路径可以写全最好）
mysqladmin -u$mysql_user -p$mysql_password flush-logs
# wc -l 统计行数
# awk 简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。
Counter=`wc -l $binlog_index |awk '{print $1}'`
NextNum=0
CopyNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的
for file in `cat $binlog_index`
do
    #basename用于截取mysql-bin.00000*文件名，去掉类似./mysql-bin.000005前面的./
    base=`basename $file`
    NextNum=`expr $NextNum + 1`
    # 跳过最新正在使用的日志
    if [ $NextNum -eq $Counter ]
    then
        echo `date +"%Y-%m-%d %H:%M:%S":` $base skip!
    else
        dest=$backup_dir/$base
        if(test -e $dest)
        #test -e用于检测目标文件是否存在，存在就写exist!到$logFile去
        then
            echo `date +"%Y-%m-%d %H:%M:%S":` $base exist!
        else
            cp $binlog_dir/$base $backup_dir
            CopyNum=`expr $CopyNum + 1`
            echo `date +"%Y-%m-%d %H:%M:%S":` $base copyed!
         fi
     fi
done
echo "备份路径：$backup_dir"
echo `date +"%Y-%m-%d %H:%M:%S":` $CopyNum new binlogs backup success!
