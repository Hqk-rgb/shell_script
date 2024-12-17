#!/bin/bash

# 指定一个目录
# 判断该目录是否存在；如果存在，则逐个拷贝该目录下的文件到新的指定目录下，要求如果有同名文件则不拷贝。

# 输入源目录和目标目录
read -p "请输入源目录路径: " source_dir
read -p "请输入目标目录路径: " target_dir

# 检查源目录是否存在
if [[ ! -d $source_dir ]]; then
    echo "源目录不存在，请检查路径！"
    exit 1
fi

# 检查目标目录是否存在，如果不存在则创建
if [[ ! -d $target_dir ]]; then
    echo "目标目录不存在，正在创建..."
    mkdir -p "$target_dir"
fi

# 遍历源目录下的文件逐个拷贝到目标目录
echo "开始拷贝文件..."
for file in "$source_dir"/*; do
    # 检查是否为文件
    if [[ -f $file ]]; then
        # 提取文件名
        filename=$(basename "$file")
        # 检查目标目录是否已有同名文件
        if [[ -e "$target_dir/$filename" ]]; then
            echo "文件 $filename 已存在，跳过拷贝。"
        else
            cp "$file" "$target_dir"
            echo "文件 $filename 已成功拷贝。"
        fi
    fi
done

echo "文件拷贝完成！"