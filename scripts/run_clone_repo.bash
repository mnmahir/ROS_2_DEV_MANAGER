#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-05-16

# To check if dev_init.bash has been sourced.
if [[ $WS_DEV_SESSION_CHECK == "" ]] || [[ $WS_DEV_SESSION_CHECK != 1 ]]  
then
 echo -e "$BASH_ERROR Make sure dev_init.bash is sourced. Refer to README.md for instructions."
 echo -e "$BASH_ACTION PRESS [ENTER] TO EXIT"
 read
 exit 0
fi

LIST_FAV_REPO=()

# Import functions and variables
source $WS_DEV_MANAGER_DIR/scripts/func_git_clone.bash
source $WS_DEV_MANAGER_DIR/config/fav_repo_list.bash


# Function to display the menu
function display_clone_repo_menu {
    echo -e "================================================="
    echo -e "$BASH_ACTION Select compatible project repository to clone:"
    echo -e "=   =   =   =   =   =   =   =   =   =   =   =   ="
    echo -e "\e[33m[0]\e[0m Use custom URL"
    INDEX=1
    for i in "${LIST_FAV_REPO[@]}"
    do
        echo -e "\e[33m[$INDEX]\e[0m $i"
        # Increment the index
        INDEX=$((INDEX+1))
    done
    echo -e "PRESS \e[33m[CTRL]\e[0m + \e[33m[C]\e[0m TO EXIT"
}

function clone_repo_menu_to_run {
    # get current path
    CURRENT_PATH=$(pwd)
    CLONE_DIR=$WS_DIR
    case $1 in
        0)
            # Use custom URL
            echo -e "$BASH_ACTION Enter the URL of the repository:"
            read -p "" REPO_URL
            echo -e "$BASH_ACTION Enter the branch/commit ID/tag of the repository (If empty will clone default branch):"
            read -p "" REPO_BRANCH
            git_clone $REPO_URL $REPO_BRANCH
            ;;
        *)
            # Clone a git workspace
            INDEX=$((choice-1))
            REPO_URL=$(echo ${LIST_FAV_REPO[$INDEX]} | cut -d' ' -f1)
            REPO_BRANCH=$(echo ${LIST_FAV_REPO[$INDEX]} | cut -d' ' -f2)
            git_clone $REPO_URL $REPO_BRANCH
            # check if bashrc_list.bash exists in $CLONE_DIR/$REPO_DIR_NAME/config/. If yes, ask whether to add to .bashrc
            if [ -f $CLONE_DIR/$REPO_DIR_NAME/config/bashrc_list.bash ]; then
                echo -e "$BASH_ACTION Do you want to add the project workspace initializer alias to .bashrc? [y/n]"
                read -p "" choice
                case $choice in
                    y)
                        echo -e "$BASH_INFO Adding aliases to .bashrc..."
                        source $CLONE_DIR/$REPO_DIR_NAME/config/settings.bash
                        source $CLONE_DIR/$REPO_DIR_NAME/config/bashrc_list.bash
                        source $WS_DEV_MANAGER_DIR/scripts/run_auto_add_bashrc.bash
                        ;;
                    n)
                        echo -e "$BASH_INFO Aliases not added to .bashrc. You may add workspace initializer alias manually to .bashrc by copying this example:"
                        echo -e "\e[33msource wsexample='$WS_DEV_INIT_PATH /$REPO_DIR_NAME /ws_robot'\e[0m"
                        ;;
                    *)
                        echo -e "$BASH_ERROR Invalid option. You may rerun or add workspace initializer alias manually to .bashrc by copying this example:"
                        echo -e "\e[33msource wsexample='$WS_DEV_INIT_PATH /$REPO_DIR_NAME /ws_robot'\e[0m"
                        ;;
                esac
            else
                echo -e "$BASH_INFO bashrc_list.bash not found in $CLONE_DIR/$REPO_DIR_NAME/config/. You may add workspace initializer alias manually to .bashrc by copying this example:"
                echo -e "\e[33msource wsexample='$WS_DEV_INIT_PATH /$REPO_DIR_NAME /ws_robot'\e[0m"
            fi
            ;;
    esac
    cd $CURRENT_PATH
}


display_clone_repo_menu
read -p "" choice
clone_repo_menu_to_run $choice
# echo selected the content of selected index
# INDEX=$((choice-1))
# REPO_URL=$(echo ${LIST_FAV_REPO[$INDEX]} | cut -d' ' -f1)
# REPO_BRANCH=$(echo ${LIST_FAV_REPO[$INDEX]} | cut -d' ' -f2)
# echo $REPO_URL $REPO_BRANCH


