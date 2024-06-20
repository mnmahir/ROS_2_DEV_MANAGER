#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-05-16
# Usage: Run this script only after initialize with dev_init.bash. Refer to README.md for instructions.
# Recommended to run by 'r2pkg' or 'source pkg_manager.bash' or '. pkg_manager.bash' to avoid issues with sourcing files.

# To check if dev_init.bash has been sourced.
if [[ $WS_DEV_SESSION_CHECK == "" ]] || [[ $WS_DEV_SESSION_CHECK != 1 ]]  
then
 echo -e "$BASH_ERROR Make sure dev_init.bash is sourced. Refer to README.md for instructions."
 echo -e "$BASH_ACTION PRESS [ENTER] TO EXIT"
 read
 exit 0
fi

# get list of directories in pkg that starts with "_"
PKG_DIR_LIST=($(ls $WS_PROJECT_REPO/pkg | grep -E "^_"))


function display_menu_1 {
    echo -e "================================================="
    echo -e "              \e[33mPACKAGE MANAGER\e[0m"
    echo -e "================================================="
    echo -e "$BASH_ACTION [1/2] Select dir to operate on:"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "Pkg Dir: \e[36m$WS_PROJECT_REPO/pkg\e[33m/\e[0m"
    echo -e "\e[33m[0]\e[0m All"
    # echo all the directories in PKG_DIR_LIST
    for ((i=0; i<${#PKG_DIR_LIST[@]}; i++))
    do
        echo -e "\e[33m[$(($i+1))]\e[0m ${PKG_DIR_LIST[$i]}"
    done
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[W]\e[0m Active Workspace: \e[36m$WS_PROJECT_REPO\e[33m$WS_PROJECT_WORKSPACE\e[0m"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[Q]\e[0m TO EXIT"
}

function display_menu_2 {
    echo -e "================================================="
    echo -e "$BASH_INFO Selected pkg dir to operate: \e[33m[$choice]\e[0m"
    echo -e "$BASH_ACTION [2/2] Select operation:"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[1]\e[0m All \e[33m[2]\e[0m to \e[33m[6]\e[0m. Refer run_pkg_operation.bash for flow of operations."
    echo -e "\e[33m[2]\e[0m Build only"
    echo -e "\e[33m[3]\e[0m Install apt & Python packages only"
    echo -e "\e[33m[4]\e[0m Git clone only"
    echo -e "\e[33m[5]\e[0m Rosdep update & install only"
    echo -e "\e[33m[6]\e[0m Execute command"
    echo -e "\e[33m[9]\e[0m Delete build, install & log directories"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[Q]\e[0m TO EXIT"
}


function run_bash_file {
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ $choice -eq 0 ]
    then
        for ((i=0; i<${#PKG_DIR_LIST[@]}; i++))
        do
            source $WS_DEV_MANAGER_DIR/scripts/run_pkg_operation.bash $2 $WS_PROJECT_REPO/pkg/${PKG_DIR_LIST[$i]}
        done
    elif [[ "$choice" =~ ^[0-9]+$ ]]
    then
        source $WS_DEV_MANAGER_DIR/scripts/run_pkg_operation.bash $2 $WS_PROJECT_REPO/pkg/${PKG_DIR_LIST[$(($choice-1))]}
    else
        source $WS_DEV_MANAGER_DIR/scripts/run_pkg_operation.bash $2 $WS_PROJECT_REPO$WS_PROJECT_WORKSPACE
    fi
}


# Main
while true
do
    clear -x
    display_menu_1
    read -p "" choice
    if [ "$choice" == "q" ] || [ "$choice" == "Q" ]
    then
        break
    fi
    if ! [[ "$choice" =~ ^[0-9wW]+$ ]] || ( [[ "$choice" =~ ^[0-9]+$ ]] && ([ $choice -gt ${#PKG_DIR_LIST[@]} ] || [ $choice -lt 0 ]) )
    then
        echo -e "$BASH_ERROR Invalid option. Please select a valid option."
    else
        display_menu_2
        read -p "" operation
        if [ "$operation" == "q" ] || [ "$operation" == "Q" ]
        then
            break
        fi
        if [ $operation -gt 9 ] || [ $operation -lt 0 ]
        then
            echo -e "$BASH_ERROR Invalid option. Please select a valid option."
        else
            if [ $operation -eq 1 ] || [ $operation -eq 3 ]
            then
                sudo apt update
            fi
            run_bash_file $choice $operation
        fi
    fi
    echo -e "$BASH_ACTION Press any key to return to menu..."
    read -n 1 -s
done
