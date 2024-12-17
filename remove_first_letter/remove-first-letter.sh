#!/bin/bash

# 按行读取文件，然后去除每行的首字母，把新内容追加到新的文件中
cat ./old.txt|while read line
do
  echo ${line:1}>>new.txt
done
