#!/bin/bash

# 0. ======= LOGGING =======
export BASH_LOG_INFO='\e[36m[INFO]\e[0m'
export BASH_LOG_ERROR='\e[31m[ERROR]\e[0m'
export BASH_LOG_WARNING='\e[33m[WARNING]\e[0m'
export BASH_LOG_SUCCESS='\e[32m[SUCCESS]\e[0m'
export BASH_LOG_ACTION='\e[35m[ACTION]\e[0m'

# 1. ======= PATH SETTINGS =======
export ROS_DEV_DIR=$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))
export ROS_DEV_MANAGER_DIR=$ROS_DEV_DIR/dev_manager
export ROS_DEV_PACKAGE_DIR=$ROS_DEV_DIR/pkg
export ROS_DEV_ROBOT_DIR=$ROS_DEV_DIR/rb
export ROS_DEV_WORKSPACE_DIR=$ROS_DEV_DIR/ws

# 2. ======= ROS SETTINGS =======
source $ROS_DEV_MANAGER_DIR/settings/dev_config.bash

# 3. ======= SET ACTIVE DEV PATHS =======
source $ROS_DEV_MANAGER_DIR/scripts/set_active_dev_path.bash

# 4. ======= ROS ENV =======
source $ROS_DEV_MANAGER_DIR/scripts/set_python_environment.bash

# 5. ======= ALIASES =======
source $ROS_DEV_MANAGER_DIR/settings/aliases.bash

# 6. ======= SOURCE FILES =======
source $ROS_DEV_MANAGER_DIR/scripts/source_files.bash

# 7. ======= DISPLAY INFO =======
source $ROS_DEV_MANAGER_DIR/scripts/display_dev_info.bash

