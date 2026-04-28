#!/bin/bash

# Display Info
alias r2info="source $ROS_DEV_MANAGER_DIR/scripts/display_dev_info.bash"

# Change Directory
alias r2cd="cd $ROS_DEV_DIR"
alias r2cdws="cd $ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE"
alias r2cdrb="cd $ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT"
alias r2cdpkg="cd $ROS_DEV_PACKAGE_DIR"
alias r2cddata="cd $ROS_DEV_DATA_DIR"

# Change Default
alias r2setws="source \$ROS_DEV_MANAGER_DIR/scripts/set_active_dev_path.bash --workspace" # Change Workspace
alias r2setrb="source \$ROS_DEV_MANAGER_DIR/scripts/set_active_dev_path.bash --robot" # Change Robot
alias r2setros="source \$ROS_DEV_MANAGER_DIR/scripts/set_dev_config.bash" # Change Base ROS Environment Defaults

# Package Manager
alias r2pkg="source \$ROS_DEV_MANAGER_DIR/scripts/pkg_manager.bash"  # Show package manager menu

# Build
alias r2b="source \$ROS_DEV_MANAGER_DIR/scripts/smart_colcon_build.bash"  # Show build menu
alias r2bws="source \$ROS_DEV_MANAGER_DIR/scripts/smart_colcon_build.bash --workspace"  # Build workspace shortcut
alias r2brb="source \$ROS_DEV_MANAGER_DIR/scripts/smart_colcon_build.bash --robot"  # Build robot shortcut
alias r2bpkg="source \$ROS_DEV_MANAGER_DIR/scripts/smart_colcon_build.bash --pkg"  # Build package shortcut
alias r2bdel="source \$ROS_DEV_MANAGER_DIR/scripts/smart_colcon_build.bash --delete"  # Delete build, install, log.
