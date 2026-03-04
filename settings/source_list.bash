#!/bin/bash

SOURCE_LIST=(
    "/opt/ros/$ROS_DISTRO/setup.bash"
    "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash"
    "$ROS_PRIMARY_BUILD_PATH/install/local_setup.bash"
)
