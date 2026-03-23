#!/bin/bash

# Define local config location
LOCAL_DEV_CONFIG="$ROS_DEV_MANAGER_DIR/local/local_dev_config.bash"
mkdir -p "$(dirname "$LOCAL_DEV_CONFIG")"
touch "$LOCAL_DEV_CONFIG"

update_local_config() {
    local key=$1
    local new_value=$2
    
    # Update or insert into the local configuration file
    if grep -q "^export $key=" "$LOCAL_DEV_CONFIG"; then
        sed -i "s|^export $key=.*|export $key=\"$new_value\"|" "$LOCAL_DEV_CONFIG"
    else
        echo "export $key=\"$new_value\"" >> "$LOCAL_DEV_CONFIG"
    fi
}

show_ros_config_menu() {
    local changed=0
    while true; do
        # Source local config dynamically so loop reflects changes locally immediately
        if [ -f "$LOCAL_DEV_CONFIG" ]; then
            source "$LOCAL_DEV_CONFIG"
        fi

        echo -e "\n\e[33m===== ROS Configuration =====\e[0m"
        echo -e "[\e[36m1\e[0m] ROS_DISTRO: \e[33m$ROS_DISTRO\e[0m"
        echo -e "[\e[36m2\e[0m] ROS_DOMAIN_ID: \e[33m$ROS_DOMAIN_ID\e[0m"
        echo -e "[\e[36m3\e[0m] RMW_IMPLEMENTATION: \e[33m$RMW_IMPLEMENTATION\e[0m"
        echo -e "[\e[36m4\e[0m] ROS_PRIMARY_PYTHON_ENV_NAME: \e[33m$ROS_PRIMARY_PYTHON_ENV_NAME\e[0m"
        echo -e "[\e[36mQ\e[0m] Exit"
        echo -e "\e[33m=============================\e[0m"
        echo -n -e "$BASH_LOG_ACTION Select parameter to change: "
        read choice
        choice=${choice,,}

        if [ "$choice" == "q" ]; then
            if [ "$changed" -eq 1 ]; then
                echo -e "\n$BASH_LOG_INFO Reloading terminal to apply new configurations..."
                exec bash
            fi
            return 0
        elif [ "$choice" == "1" ]; then
            echo -n -e "$BASH_LOG_ACTION Enter new ROS_DISTRO [current: \e[33m$ROS_DISTRO\e[0m]: "
            read new_val
            if [ -n "$new_val" ]; then
                update_local_config "ROS_DISTRO" "$new_val"
                echo -e "$BASH_LOG_SUCCESS Updated ROS_DISTRO to: $new_val"
                changed=1
            fi
        elif [ "$choice" == "2" ]; then
            echo -n -e "$BASH_LOG_ACTION Enter new ROS_DOMAIN_ID [current: \e[33m$ROS_DOMAIN_ID\e[0m]: "
            read new_val
            if [ -n "$new_val" ]; then
                update_local_config "ROS_DOMAIN_ID" "$new_val"
                echo -e "$BASH_LOG_SUCCESS Updated ROS_DOMAIN_ID to: $new_val"
                changed=1
            fi
        elif [ "$choice" == "3" ]; then
            echo -n -e "$BASH_LOG_ACTION Enter new RMW_IMPLEMENTATION [current: \e[33m$RMW_IMPLEMENTATION\e[0m]: "
            read new_val
            if [ -n "$new_val" ]; then
                update_local_config "RMW_IMPLEMENTATION" "$new_val"
                echo -e "$BASH_LOG_SUCCESS Updated RMW_IMPLEMENTATION to: $new_val"
                changed=1
            fi
        elif [ "$choice" == "4" ]; then
            echo -n -e "$BASH_LOG_ACTION Enter new ROS_PRIMARY_PYTHON_ENV_NAME [current: \e[33m$ROS_PRIMARY_PYTHON_ENV_NAME\e[0m]: "
            read new_val
            if [ -n "$new_val" ] && [ "$new_val" != "$ROS_PRIMARY_PYTHON_ENV_NAME" ]; then
                update_local_config "ROS_PRIMARY_PYTHON_ENV_NAME" "$new_val"
                echo -e "$BASH_LOG_SUCCESS Updated ROS_PRIMARY_PYTHON_ENV_NAME to: $new_val"
                changed=1
                echo -e "\n$BASH_LOG_WARNING \e[33mIMPORTANT: Reinitialization is required for Python Environment changes to fully take effect! The new name means it will create a fresh python virtual environment, and you may need to re-run r2pkg setup to redownload your dependency packages.\e[0m"
            fi
        else
            echo -e "$BASH_LOG_ERROR Invalid choice. Please try again."
        fi
    done
}

show_ros_config_menu
