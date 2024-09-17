#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-06-11

DEV_MANAGER_REVISION=20240917

###### GLOBAL ENVIRONMENT ######
export WS_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
export WS_DEV_INIT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/dev_init.bash"
export WS_DEV_MANAGER_DIR_NAME="$(basename $(dirname "$(readlink -f "${BASH_SOURCE[0]}")"))"
export WS_DEV_MANAGER_DIR="$WS_DIR/$WS_DEV_MANAGER_DIR_NAME"


###### PROJECT ENVIRONMENT ######
export WS_PROJECT_REPO="$WS_DIR${1:-/$WS_DEV_MANAGER_DIR_NAME/template}"
export WS_PROJECT_WORKSPACE="${2:-/ws_robot}"


###### DEVELOPMENT SESSION ######
source $WS_DEV_MANAGER_DIR/config/settings.bash
source $WS_PROJECT_REPO/config/init.bash
source $WS_PROJECT_REPO/config/settings.bash    # If contain duplicate, this will overwrite settings from dev_manager.
source $WS_DEV_MANAGER_DIR/config/aliases.bash
source $WS_PROJECT_REPO/config/aliases.bash     # If contain duplicate, this will overwrite aliases from dev_manager.
export WS_DEV_SESSION_CHECK=1



###### DISPLAY ######
clear -x
echo -e "\e[33m===================================================================
            ROS 2 Development Manager (by Mahir Sehmi)
==================================================================="
echo -e "$BASH_INFO Initializing..."
if [ "$WS_DEV_MANAGER_REVISION" -lt "$DEV_MANAGER_REVISION" ]; then
	echo -e "$BASH_WARNING The current project is using development manager revision \e[36m$WS_DEV_MANAGER_REVISION\e[0m which is older than current manager revision \e[36m$DEV_MANAGER_REVISION\e[0m. You may continue using but some features may not work. Please use older version or upgrade current project repo following the latest content."
fi

if [ "$WS_DEV_MANAGER_REVISION" -gt "$DEV_MANAGER_REVISION" ]; then
	echo -e "$BASH_WARNING The current project is using development manager revision \e[36m$WS_DEV_MANAGER_REVISION\e[0m which is newer than current manager revision \e[36m$DEV_MANAGER_REVISION\e[0m. You may continue using but some features may not work. Please upgrade the manager."
fi
echo "==================================================================="
r2info
echo "==================================================================="
r2s
r2cdw
