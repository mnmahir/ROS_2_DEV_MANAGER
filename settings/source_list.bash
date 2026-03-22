#!/bin/bash

LOCAL_BUILD_SETTING="$ROS_DEV_MANAGER_DIR/local/colcon_build_setting.bash"
if [ -f "$LOCAL_BUILD_SETTING" ]; then
    source "$LOCAL_BUILD_SETTING"
fi

SOURCE_LIST=(
    "/opt/ros/$ROS_DISTRO/setup.bash"
    "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash"
)

if [[ "$COLCON_BUILD_PATH_MODE" == "1" ]]; then
    # Centralized
    SOURCE_LIST+=("$ROS_PRIMARY_BUILD_PATH/install/local_setup.bash")
else
    # Modular (0 or undefined)
    SOURCE_LIST+=("$ROS_DEV_PACKAGE_DIR/install/local_setup.bash")
    if [ -n "$ROS_DEV_ROBOT" ]; then
        SOURCE_LIST+=("$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/install/local_setup.bash")
    fi
    if [ -n "$ROS_DEV_WORKSPACE" ]; then
        SOURCE_LIST+=("$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/install/local_setup.bash")
    fi
fi
