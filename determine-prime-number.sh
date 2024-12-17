#!/bin/bash
# 判断素数
read -p "请输入一个数字: " num

# 判断输入是否为正整数
if ! [[ "$num" =~ ^[0-9]+$ ]]; then
   if [[ "$num" -eq 0 ]]; then
        echo "$num 不是素数"
    else
        echo "$num 不是正整数，脚本结束。"
    fi
    exit 1  # 不是正整数或输入为 0 时终止脚本
fi

# 判读素数的函数定义
# 返回1表示该数字不是素数，反之则为素数
determinPrimeNumber(){
  if [[ "$1" -lt 2 ]];then
    return 1
  elif [[ "$1" -eq 2 ]];then
    return 0
  else
      # i<=$1/2：循环的条件是 i 小于等于 $1/2。
      # 也就是说，只检查 $1 的因数是否存在于 2 到 $1 的一半之间即可，因为一个数的因数不会超过它的一半。
      for (( i=2;i<="$1"/2;i++ ));do
          # 计算 $1 除以 i 的余数,余数为0说明能被整除，表明这个数字不是素数
          if (( $1%i==0 ));then
             return 1
          fi
     done
     # 上述条件不满足则表明这是一个素数
     return 0
fi
}

#调用函数
determinPrimeNumber $num
# 用$?来接受上一条命令执行的结果，这里就是获取函数中的返回值
result=$?
if [[ $result -eq 0 ]];then
   echo "$num是素数"
else
   echo "$num不是素数"
fi

# 打印101-200内所有素数
for (( j=101;j<=200;j++ ))
do
determinPrimeNumber $j
res=$?
if (( res==0 ));then
   echo -n $j" "
fi
done
echo ""







