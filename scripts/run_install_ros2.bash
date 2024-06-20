#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-05-15
# Usage: Run this script to install ROS 2

if [[ $WS_DEV_SESSION_CHECK == "" ]] || [[ $WS_DEV_SESSION_CHECK != 1 ]]  
then
 echo -e "$BASH_ERROR Make sure dev_init.bash is sourced. Refer to README.md for instructions."
 echo -e "$BASH_ACTION PRESS [ENTER] TO EXIT"
 read
 exit 0
fi


echo -e "========================= NOTE ========================="
echo -e "Welcome to ROS Installer (Debian)"
echo -e "Target ROS distro: \e[36m$ROS_DISTRO\e[0m"
echo -e "Target OS: \e[36m$OS_DISTRO\e[0m"
echo -e "========================================================"
echo "PRESS [ENTER] TO CONTINUE"
echo "PRESS [CTRL] + [C] TO CANCEL"
read
sudo test

#############################
# Set Locale
#############################
if [[ $LANG == "en_US.UTF-8" ]]
then
  locale
  echo -e "$BASH_INFO Locale already set to en_US.UTF-8."
else
  echo -e "$BASH_INFO Setting locale to en_US.UTF-8."
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
  export LANG=en_US.UTF-8
  # check again if locale are set
  if [[ $LANG == "en_US.UTF-8" ]]
  then
    locale
    echo -e "$BASH_SUCCESS Locale set to en_US.UTF-8."
  else
    locale
    echo -e "$BASH_ERROR Locale not set to en_US.UTF-8. Process will not continue. Exiting..."
    exit 0
  fi
fi

#############################
# Setup Sources
#############################
# check if sources are added. if not add it.
if [[ -f /etc/apt/sources.list.d/ros2.list ]]
then
  echo -e "$BASH_INFO ROS 2 sources already added."
else
  sudo apt install software-properties-common
  sudo add-apt-repository universe

  sudo apt update && sudo apt install curl -y
  sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $OS_DISTRO main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
  # check again if sources are added
  if [[ -f /etc/apt/sources.list.d/ros2.list ]]
  then
    echo -e "$BASH_SUCCESS ROS 2 sources added."
  else
    echo -e "$BASH_ERROR ROS 2 sources not added. Process will not continue. Exiting..."
    exit 0
  fi
fi


#############################
# Install ROS 2 packages
#############################
sudo apt update
sudo apt upgrade
sudo apt install ros-$ROS_DISTRO-desktop -y
sudo apt install ros-dev-tools -y
sudo rosdep init

#############################
# Source ROS 2
#############################
# check if ROS 2 is installed. If yes, source it. If not, exit.
if [[ -f /opt/ros/$ROS_DISTRO/setup.bash ]]
then
  source /opt/ros/$ROS_DISTRO/setup.bash
  echo -e "$BASH_SUCCESS ROS 2 sourced from \e[36m/opt/ros/$ROS_DISTRO/setup.bash.\e[0m"
else
  echo -e "$BASH_ERROR ROS 2 not installed. Process will not continue. Exiting..."
  exit 0
fi
echo -e "$BASH_INFO Exiting ROS installer."