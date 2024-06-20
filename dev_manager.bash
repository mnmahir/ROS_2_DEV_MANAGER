#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-05-16
# Usage: Run this script only after initialize with dev_init.bash. Refer to README.md for instructions.
# Recommended to run by 'source dev_manager.bash' or '. dev_manager.bash' to avoid issues with sourcing files.


function display_main_menu {
    echo -e "================================================="
    echo -e "              \e[33mDEVELOPMENT MANAGER\e[0m"
    echo -e "================================================="
    echo -e "$BASH_ACTION Select an option:"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[1]\e[0m Install ROS2"
    echo -e "\e[33m[2]\e[0m Install Recommended Software"
    echo -e "\e[33m[3]\e[0m Clone a project from GitHub"
    echo -e "\e[33m[4]\e[0m Create a new project using template"
    echo -e "\e[33m[5]\e[0m Add alias to .bashrc"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[Q]\e[0m TO EXIT"
}

function main_menu_to_run {
    case $1 in
        1)
            # Install ROS2
            source $WS_DEV_MANAGER_DIR/scripts/run_install_ros2.bash
            ;;
        2)
            # Install Recommended Software
            source $WS_DEV_MANAGER_DIR/config/recommended_pkg.bash
            source $WS_DEV_MANAGER_DIR/scripts/func_pkg_operation.bash
            install_apt_packages
            ;;
        3)
            # Clone a git workspace
            source $WS_DEV_MANAGER_DIR/scripts/run_clone_repo.bash
            ;;
        4)
            # Create a new workspace using template
            echo -e "$BASH_INFO Under construction... Coming soon!"
            echo -e "$BASH_INFO For the time being, you make a copy of the template workspace manually and rename it."
            echo -e "$BASH_INFO Then add alias to .bashrc using this format: "
            echo -e "$BASH_INFO \e[33malias <alias>='source $WS_DEV_INIT_PATH <repo dir> <ws dir>'\e[0m"
            echo -e "$BASH_INFO <repo dir> is relative to WORKSPACE dir. <ws dir> is relative to repo dir. "
            ;;
        5)
            # Add alias to .bashrc
            source $WS_DEV_MANAGER_DIR/scripts/run_auto_add_bashrc.bash $WS_PROJECT_REPO/config/bashrc_list.bash
            ;;
        *)
            echo -e "$BASH_ERROR Invalid option. Please select a valid option."
            ;;
    esac
}

# Main
while true
do
    clear -x
    display_main_menu
    
    read -p "" choice
    if [ "$choice" == "q" ] || [ "$choice" == "Q" ]
    then
        break
    fi
    main_menu_to_run $choice
    echo -e "$BASH_ACTION Press any key to return to menu..."
    read -n 1 -s
done




