#!/bin/bash
echo -e "\033[30m 黑色字 \033[0m"
echo -e "\033[31m 红色字 \033[0m"
echo -e "\033[32m 绿色字 \033[0m"
echo -e "\033[33m 黄色字 \033[0m"
echo -e "\033[34m 蓝色字 \033[0m"
echo -e "\033[35m 紫色字 \033[0m"
echo -e "\033[36m 天蓝字 \033[0m"
echo -e "\033[37m 白色字 \033[0m"

#字背景颜色范围：40-47 
echo -e "\033[40;37m 黑底白字 \033[0m"
echo -e "\033[41;30m 红底黑字 \033[0m"
echo -e "\033[42;34m 绿底蓝字 \033[0m"
echo -e "\033[43;34m 黄底蓝字 \033[0m"
echo -e "\033[44;30m 蓝底黑字 \033[0m"
echo -e "\033[45;30m 紫底黑字 \033[0m"
echo -e "\033[46;30m 天蓝底黑字 \033[0m"
echo -e "\033[47;34m 白底蓝字 \033[0m"

#!/bin/bash
 
# 设置颜色变量
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
RESET='\033[0m'
BOLD="\033[1m" 
UNDERLINE="\033[4m"   # 下划线
 
# 使用颜色输出文本
echo -e "${RED}This is red text.${RESET}"
echo -e "${GREEN}This is green text.${RESET}"
echo -e "${YELLOW}This is yellow text.${RESET}"
echo -e "${BLUE}This is blue text.${RESET}"
echo -e "${MAGENTA}This is magenta text.${RESET}"
echo -e "${CYAN}This is cyan text.${RESET}"
echo -e "${WHITE}This is white text.${RESET}"
 
# 设置粗体文本
echo -e "${RED}${BOLD}This is red bold text.${RESET}"
 
# 设置下划线文本
echo -e "${BLUE}${UNDERLINE}This is blue underlined text.${RESET}"