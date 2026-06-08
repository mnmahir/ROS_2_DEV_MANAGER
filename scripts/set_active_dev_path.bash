#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

LOCAL_PATH_FILE="$ROS_DEV_MANAGER_DIR/local/active_dev_path.bash"

# 1. Check if local active_dev_path.bash exists, if not create it
if [ ! -f "$LOCAL_PATH_FILE" ]; then
    mkdir -p "$(dirname "$LOCAL_PATH_FILE")"
    echo "ROS_DEV_ROBOT=None" > "$LOCAL_PATH_FILE"
    echo "ROS_DEV_WORKSPACE=None" >> "$LOCAL_PATH_FILE"
fi

# 2. Source the local active_dev_path to get current values (ROS_DEV_ROBOT and ROS_DEV_WORKSPACE)
source "$LOCAL_PATH_FILE"

# Function to update the active_dev_path.bash
update_active_dev_path() {
    echo "ROS_DEV_ROBOT=$ROS_DEV_ROBOT" > "$LOCAL_PATH_FILE"
    echo "ROS_DEV_WORKSPACE=$ROS_DEV_WORKSPACE" >> "$LOCAL_PATH_FILE"
}

# Function to populate a new workspace with template files if they are missing
setup_workspace_if_new() {
    local ws_path="$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE"
    local template_path="$ROS_DEV_MANAGER_DIR/template/ws"

    if [ ! -d "$ws_path/src" ]; then
        mkdir -p "$ws_path/src"
        echo -e "$BASH_LOG_INFO Created src/ directory in workspace."
    fi

    if [ ! -f "$ws_path/pkg_list.bash" ] && [ -f "$template_path/pkg_list.bash" ]; then
        cp "$template_path/pkg_list.bash" "$ws_path/pkg_list.bash"
        echo -e "$BASH_LOG_INFO Copied template pkg_list.bash to workspace."
    fi

    if [ ! -f "$ws_path/.gitignore" ] && [ -f "$template_path/.gitignore" ]; then
        cp "$template_path/.gitignore" "$ws_path/.gitignore"
        echo -e "$BASH_LOG_INFO Copied template .gitignore to workspace."
    fi
}

# Function to populate a new robot directory with template files if they are missing
setup_robot_if_new() {
    local rb_path="$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT"
    local template_path="$ROS_DEV_MANAGER_DIR/template/rb"

    if [ ! -d "$rb_path/src" ]; then
        mkdir -p "$rb_path/src"
        echo -e "$BASH_LOG_INFO Created src/ directory in robot."
    fi

    if [ ! -d "$rb_path/scripts" ]; then
        mkdir -p "$rb_path/scripts"
        echo -e "$BASH_LOG_INFO Created scripts/ directory in robot."
    fi

    if [ ! -f "$rb_path/pkg_list.bash" ] && [ -f "$template_path/pkg_list.bash" ]; then
        cp "$template_path/pkg_list.bash" "$rb_path/pkg_list.bash"
        echo -e "$BASH_LOG_INFO Copied template pkg_list.bash to robot."
    fi

    if [ ! -f "$rb_path/.gitignore" ] && [ -f "$template_path/.gitignore" ]; then
        cp "$template_path/.gitignore" "$rb_path/.gitignore"
        echo -e "$BASH_LOG_INFO Copied template .gitignore to robot."
    fi
}

# Generic Menu function
# Arguments: target_dir, title, var_name
show_menu() {
    local target_dir=$1
    local title=$2
    local var_name=$3
    
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    local page=0
    
    while true; do
        local items=()
        for d in "$target_dir"/*/; do
            if [ -d "$d" ]; then
                local base_d=$(basename "$d")
                items+=("$base_d")
            fi
        done
        
        local num_items=${#items[@]}
        local items_per_page=5
        
        local total_pages=$(( (num_items + items_per_page - 1) / items_per_page ))
        if [ "$total_pages" -eq 0 ]; then
            total_pages=1
        fi
        
        while true; do
            echo -e "\n\e[33m===== $title =====\e[0m"
            
            local start_idx=$((page * items_per_page))
            local end_idx=$((start_idx + items_per_page))
            if [ $end_idx -gt $num_items ]; then
                end_idx=$num_items
            fi
            
            local option_idx=1
            local current_page_items=()
            
            for ((i=start_idx; i<end_idx; i++)); do
                echo -e "[\e[36m$option_idx\e[0m] ${items[$i]}"
                current_page_items+=("${items[$i]}")
                ((option_idx++))
            done
            
            echo -e "\e[33m======= Page $((page + 1))/$total_pages =======\e[0m"
            echo -e "[\e[36m0\e[0m] \"Create New\""
            
            if [ "$end_idx" -lt "$num_items" ]; then
                echo -e "[\e[36mN\e[0m] Next page"
            fi
            
            if [ "$page" -gt 0 ]; then
                echo -e "[\e[36mP\e[0m] Previous page"
            fi

            echo -e "[\e[36mQ\e[0m] Cancel"
            echo -e "\e[33m========================\e[0m"
            echo -n -e "$BASH_LOG_ACTION Select an option: "
            read user_choice
            
            # Keep original case logic in case ${,,} doesn't work correctly on some systems
            
            if [[ "$user_choice" =~ ^[1-5]$ ]]; then
                if [ "$user_choice" -le ${#current_page_items[@]} ]; then
                    local idx=$((user_choice - 1))
                    export $var_name="${current_page_items[$idx]}"
                    
                    local selected_val="${current_page_items[$idx]}"
                    local item_name=${title#"Select "}
                    echo -e "$BASH_LOG_INFO $item_name selected: \e[36m$selected_val\e[0m"
                    return 0
                else
                    echo -e "\e[31mInvalid choice. Please try again.\e[0m"
                fi
            elif [ "$user_choice" == "0" ]; then
                echo -n "Enter new name: "
                read new_name
                if [ -n "$new_name" ]; then
                    mkdir -p "$target_dir/$new_name"
                    export $var_name="$new_name"
                    local item_name=${title#"Select "}
                    echo -e "$BASH_LOG_INFO $item_name selected: \e[36m$new_name\e[0m"
                    return 0
                else
                    echo -e "\e[31mInvalid name. Please try again.\e[0m"
                fi
            elif [[ "$user_choice" =~ ^[nN]$ ]]; then
                if [ "$end_idx" -lt "$num_items" ]; then
                    page=$((page + 1))
                    break # break inner loop to re-render
                else
                    echo -e "\e[31mInvalid choice. Please try again.\e[0m"
                fi
            elif [[ "$user_choice" =~ ^[pP]$ ]]; then
                if [ "$page" -gt 0 ]; then
                    page=$((page - 1))
                    break # break inner loop to re-render
                else
                    echo -e "\e[31mInvalid choice. Please try again.\e[0m"
                fi
            elif [[ "$user_choice" =~ ^[qQ]$ ]]; then
                return 1
            else
                echo -e "\e[31mInvalid input.\e[0m"
            fi
        done
    done
}

# 3. Check arguments or missing paths
# If aliases call with --robot or --workspace
if [ "$1" == "--robot" ]; then
    if show_menu "$ROS_DEV_ROBOT_DIR" "Select Robot" "ROS_DEV_ROBOT"; then
        update_active_dev_path
        setup_robot_if_new
    fi
elif [ "$1" == "--workspace" ]; then
    if show_menu "$ROS_DEV_WORKSPACE_DIR" "Select Workspace" "ROS_DEV_WORKSPACE"; then
        update_active_dev_path
        setup_workspace_if_new
    fi
else
    # Check if current ROS_DEV_ROBOT exists
    if [ "$ROS_DEV_ROBOT" == "None" ] || [ ! -d "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT" ]; then
        if show_menu "$ROS_DEV_ROBOT_DIR" "Select Robot" "ROS_DEV_ROBOT"; then
            update_active_dev_path
            setup_robot_if_new
        fi
    fi

    # Check if current ROS_DEV_WORKSPACE exists
    if [ "$ROS_DEV_WORKSPACE" == "None" ] || [ ! -d "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE" ]; then
        if show_menu "$ROS_DEV_WORKSPACE_DIR" "Select Workspace" "ROS_DEV_WORKSPACE"; then
            update_active_dev_path
            setup_workspace_if_new
        fi
    fi
    
    export ROS_DEV_ROBOT
    export ROS_DEV_WORKSPACE
fi