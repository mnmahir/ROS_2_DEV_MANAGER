#!/bin/bash
# ======= ENVIRONMENT =======
export DEV_PROJECT_NAME="TEMPLATE"      # Short name is preferred. Only alphanumeric characters and underscores are allowed.
export OS_DISTRO=$(. /etc/os-release && echo $UBUNTU_CODENAME)
export WS_PROJECT_REPO_DIR_NAME="$(basename $(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"))"


# ======= ROS SETTINGS ======
export ROS_DISTRO=humble
export ROS_DOMAIN_ID=8
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_LOCALHOST_ONLY=0 #0 default behavior, attach dds to prefered interface
						    #1 to enable to loopback only. But need to add mcast address
						    # route add -net 224.0.0.0 netmask 240.0.0.0 dev lo
						    # ifconfig lo multicast


# ======= LOGGING =======
export RCUTILS_COLORIZED_OUTPUT=1
# export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}][{name}][{time}]: {message} ({function_name}() at {file_name}:{line_number})"
# export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}][{name}][{time}]: {message}"


# ======= GPU ACCELERATION ======= (If using "NVIDIA On-Demand" PRIME profile, uncomment below to run/offload GPU supported application. No need if using "NVIDIA Performance Mode".)
# export __NV_PRIME_RENDER_OFFLOAD=1
# export __GLX_VENDOR_LIBRARY_NAME=nvidia
