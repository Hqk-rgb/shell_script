#!/bin/bash
# 定义数组
data=(34 7 23 99 2 67 0)
# 打印排序前的数组
echo "排序前数组：${data[@]}"
# 冒泡排序实现
# 定义数组长度
len=${#data[@]}
for (( i=0;i<len-1;i++ ));do
    for (( j=0;j<len-i-1;j++ ));do
        if (( data[j]>data[j+1] ));then
           # 交换元素
           temp=${data[j]}
           data[j]=${data[j+1]}
           data[j+1]=$temp
        fi
    done
done
# 打印排序后的数组
echo "排序后数组：${data[@]}"

min=${data[0]}
max=${data[len-1]}

echo "最大值：$max"
echo "最小值：$min"