#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

echo -e "\e[33m======================= ROS DEV INFO ============================\e[0m"
echo -e "\e[33mDevelopment Directory: \e[36m$ROS_DEV_DIR\e[0m"
echo -e "\e[33m--> Data Directory: \e[36m$ROS_DATA_DIR\e[0m (use \e[36mROS_DATA_DIR\e[0m)"
echo -e "\e[33m--> Output Directory: \e[36m$ROS_OUTPUT_DIR\e[0m (use \e[36mROS_OUTPUT_DIR\e[0m)"
echo -e "\e[33mActive Robot: \e[36m$ROS_DEV_ROBOT_DIR/\e[31m$ROS_DEV_ROBOT\e[0m"
echo -e "\e[33mActive Workspace: \e[36m$ROS_DEV_WORKSPACE_DIR/\e[31m$ROS_DEV_WORKSPACE\e[0m"
echo -e "\e[33mOS Distro: \e[36m$OS_DISTRO\e[0m"
echo -e "\e[33mROS Distro: \e[36m$ROS_DISTRO\e[0m"
echo -e "\e[33mRMW Implementation: \e[36m$RMW_IMPLEMENTATION\e[0m"
echo -e "\e[33mROS ID: \033[5m\e[31m$ROS_DOMAIN_ID\e[0m"
IPs=""; for ip in $(hostname -I); do IPs+="$ip | "; done; IPs=${IPs::-3}; echo -e "\e[33mCurrent IP: \e[36m$IPs\e[0m"
echo -e "\e[33m=================================================================\e[0m"
echo -e "'\e[33mr2setws\e[0m' to switch workspace. '\e[33mr2setrb\e[0m' to switch robot."