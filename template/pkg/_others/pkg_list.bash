#!/bin/bash
LIST_GIT_REPO=(     # List of git repositories to be cloned ("Git URL" "Commit ID/Tag/Branch"). Preferably use commit id / tag for reproducibility.
    # "https://github.com/ros-navigation/navigation2.git 6cee761a83c547b57673b5310b15b5e9e27e4d2f"
    # "https://github.com/SteveMacenski/slam_toolbox.git 94cec982a7f850818187c81295d1212f145efe37"
    # "https://github.com/cra-ros-pkg/robot_localization.git 51f48237ab8b60d27518dad3301ea8bd7138d155"
)


LIST_APT_PKG=(  # List of apt packages to be installed ("Package Name" "--optional-flag")
    # "ros-$ROS_DISTRO-rqt*"
    # "ros-$ROS_DISTRO-rviz2"
    # "ros-$ROS_DISTRO-rviz*"
)


LIST_PYTHON_PKG=(   # List of python packages to be installed ("Package Name" "--optional-flag")
    # "lark"
    # "xacro"
)


LIST_EXEC_CMD=(     # List of commands to be executed ("Command")
    # "echo -e $BASH_INFO Hello World"
    # "echo -e $BASH_INFO Bye World"
)