#!/bin/bash
# ======= ENVIRONMENT =======
export OS_DISTRO=$(. /etc/os-release && echo $UBUNTU_CODENAME)

# ======= ROS SETTINGS ======
export ROS_DISTRO=jazzy
export ROS_DOMAIN_ID=30
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Useable path variable after deploying the package. Recommended to use this variable in the code.
export ROS_OUTPUT_DIR=$ROS_DEV_DIR/output
export ROS_DATA_DIR=$ROS_DEV_DIR/data

# Primary build path
export ROS_PRIMARY_BUILD_PATH=$ROS_DEV_DIR/output/ros

# ======= PYTHON SETTINGS =======
export ROS_PRIMARY_PYTHON_ENV_NAME="ros2"     # Name of the python environment. Empty string will use the system python environment.
# export ROS_PRIMARY_PYTHON_ENV_VERSION=""      # FUTURE TODO: Version of the python environment. Empty string will use the default python version installed in the system.

# Above this line, you are allowed to change the value of the variables.
# But, not recommended to change the name of the variable as it is being used by the manager tool.

# ======= LOCAL OVERRIDES =======
LOCAL_DEV_CONFIG="$ROS_DEV_DIR/dev_manager/local/local_dev_config.bash"
if [ -f "$LOCAL_DEV_CONFIG" ]; then
    source "$LOCAL_DEV_CONFIG"
fi

# ======= LOGGING =======
export RCUTILS_COLORIZED_OUTPUT=1
export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity} {time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})"
export GTEST_COLOR=1

# ======= GPU ACCELERATION ======= (If using "NVIDIA On-Demand" PRIME profile, uncomment below to run/offload GPU supported application. No need if using "NVIDIA Performance Mode".)
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# ======= GAZEBO SETTINGS =======
export GZ_SIM_RESOURCE_PATH="${GZ_SIM_RESOURCE_PATH:+$GZ_SIM_RESOURCE_PATH:}$ROS_DATA_DIR/3d_models/gz_models/my_models:$ROS_DATA_DIR/3d_models/gz_models/gazebo_models"
