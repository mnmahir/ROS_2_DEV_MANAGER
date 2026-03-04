#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

# Configuration and State
LOCAL_BUILD_SETTING="$ROS_DEV_MANAGER_DIR/local/colcon_build_setting.bash"

# Initialize local build setting if missing
if [ ! -f "$LOCAL_BUILD_SETTING" ]; then
    mkdir -p "$(dirname "$LOCAL_BUILD_SETTING")"
    echo "COLCON_BUILD_MODE=1" > "$LOCAL_BUILD_SETTING"
fi
source "$LOCAL_BUILD_SETTING"

# Ensure colcon log outputs to the correct directory
export COLCON_LOG_PATH="$ROS_PRIMARY_BUILD_PATH/log"

# Helpers
get_active_pkg_collections() {
    local collections=()
    if [ -d "$ROS_DEV_PACKAGE_DIR" ]; then
        for d in "$ROS_DEV_PACKAGE_DIR"/_*; do
            if [ -d "$d" ] && [ -f "$d/pkg_list.bash" ]; then
                local is_ignored=$(bash -c "source \"$d/pkg_list.bash\" && echo \$PKG_IGNORE")
                if [ "${is_ignored,,}" != "true" ]; then
                    collections+=("$d")
                fi
            fi
        done
    fi
    echo "${collections[@]}"
}

get_build_command() {
    local base_paths=("$@")
    
    # Base arguments for setting output destinations
    local cmd="colcon build --build-base $ROS_PRIMARY_BUILD_PATH/build --install-base $ROS_PRIMARY_BUILD_PATH/install"
    
    if [ ${#base_paths[@]} -gt 0 ]; then
        cmd="$cmd --base-paths ${base_paths[*]}"
    fi

    # Append mode flags
    if [ "$COLCON_BUILD_MODE" == "2" ]; then
        # Release
        cmd="$cmd --cmake-args -DCMAKE_BUILD_TYPE=Release"
    else
        # Basic
        cmd="$cmd --symlink-install"
    fi

    echo "$cmd"
}

run_build() {
    local name=$1
    shift
    local paths=("$@")
    
    if [ ${#paths[@]} -eq 0 ]; then
        echo -e "$BASH_LOG_WARNING No paths provided to build $name."
        return
    fi
    
    echo -e "\n$BASH_LOG_INFO Building: $name"
    for p in "${paths[@]}"; do
        echo -e "  - \e[36m$p\e[0m"
    done
    
    local cmd=$(get_build_command "${paths[@]}")
    echo -e "$BASH_LOG_INFO Command: \e[33m$cmd\e[0m"
    
    # Execute build
    if eval "$cmd"; then
        local setup_script="$ROS_PRIMARY_BUILD_PATH/install/setup.bash"
        if [ -f "$setup_script" ]; then
            source "$setup_script"
            echo -e "$BASH_LOG_SUCCESS Sourced setup environment: \e[36m$setup_script\e[0m"
        else
            echo -e "$BASH_LOG_WARNING Could not find setup script: \e[36m$setup_script\e[0m"
        fi
    else
        echo -e "\n$BASH_LOG_ERROR Build failed."
    fi
}

delete_build_folders() {
    echo -e "\n\e[33m===== Delete Build Directories =====\e[0m"
    local build_dir="$ROS_PRIMARY_BUILD_PATH/build"
    local install_dir="$ROS_PRIMARY_BUILD_PATH/install"
    local log_dir="$ROS_PRIMARY_BUILD_PATH/log" # colcon creates log in PWD or workspace root usually, we configure if possible or just clear the default ros log

    # Colcon default logs output to workspace root `log/`.
    local colcon_log_dir="$ROS_DEV_DIR/log"

    if [ -d "$build_dir" ]; then
        echo -n -e "$BASH_LOG_ACTION Delete build folder ($build_dir)? (y/N): "
        read ans
        if [[ "${ans,,}" == "y" ]]; then
            rm -rf "$build_dir"
            echo -e "$BASH_LOG_SUCCESS Deleted $build_dir"
        fi
    fi

    if [ -d "$install_dir" ]; then
        echo -n -e "$BASH_LOG_ACTION Delete install folder ($install_dir)? (y/N): "
        read ans
        if [[ "${ans,,}" == "y" ]]; then
            rm -rf "$install_dir"
            echo -e "$BASH_LOG_SUCCESS Deleted $install_dir"
        fi
    fi

    if [ -d "$log_dir" ]; then
        echo -n -e "$BASH_LOG_ACTION Delete log folder ($log_dir)? (y/N): "
        read ans
        if [[ "${ans,,}" == "y" ]]; then
            rm -rf "$log_dir"
            echo -e "$BASH_LOG_SUCCESS Deleted $log_dir"
        fi
    fi
}

change_build_setting() {
    echo -e "\n\e[33m===== Change Build Setting =====\e[0m"
    echo -e "[\e[36m1\e[0m] Basic (e.g. colcon build --symlink-install)"
    echo -e "[\e[36m2\e[0m] Release (e.g. colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release)"
    echo -e "[\e[36mQ\e[0m] Cancel"
    echo -e "\e[33m================================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select setting: "
    read mode_choice
    mode_choice=${mode_choice,,}
    
    if [ "$mode_choice" == "q" ]; then
        return 0
    elif [[ "$mode_choice" == "1" ]] || [[ "$mode_choice" == "2" ]]; then
        echo "COLCON_BUILD_MODE=$mode_choice" > "$LOCAL_BUILD_SETTING"
        export COLCON_BUILD_MODE=$mode_choice
        echo -e "$BASH_LOG_SUCCESS Build setting updated."
    else
        echo -e "$BASH_LOG_ERROR Invalid choice. Setting unchanged."
    fi
}

# --- CLI Argument Parsing ---

if [[ "$1" == "--workspace" ]]; then
    run_build "Workspace" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE"
    return 0
elif [[ "$1" == "--robot" ]]; then
    run_build "Robot" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT"
    return 0
elif [[ "$1" == "--pkg" ]]; then
    active_pkgs=($(get_active_pkg_collections))
    run_build "Enabled Packages" "${active_pkgs[@]}"
    return 0
elif [[ "$1" == "--delete" ]]; then
    delete_build_folders
    return 0
fi

# --- Main Menu ---

while true; do
    mode_str="Basic"
    if [ "$COLCON_BUILD_MODE" == "2" ]; then
        mode_str="Release"
    fi

    echo -e "\n\e[33m===== Smart Colcon Build =====\e[0m"
    echo -e "[\e[36m1\e[0m] Build all"
    echo -e "[\e[36m2\e[0m] Build workspace only \e[36m(r2bws)\e[0m - \e[35m$ROS_DEV_WORKSPACE\e[0m"
    echo -e "[\e[36m3\e[0m] Build robot only \e[36m(r2brb)\e[0m - \e[35m$ROS_DEV_ROBOT\e[0m"
    echo -e "[\e[36m4\e[0m] Build enabled pkg only \e[36m(r2bpkg)\e[0m"
    echo -e "[\e[36m9\e[0m] Delete build, install & log folder \e[36m(r2bdel)\e[0m at \e[35m$ROS_PRIMARY_BUILD_PATH\e[0m"
    echo -e "[\e[36m0\e[0m] Change build setting"
    echo -e "[\e[36mQ\e[0m] Exit"
    echo -e "\e[33m==============================\e[0m"
    echo -e "Build setting: ($COLCON_BUILD_MODE) $mode_str"
    echo -e "Build output path: \e[35m$ROS_PRIMARY_BUILD_PATH\e[0m"
    echo -e "\e[33m==============================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read build_choice
    
    build_choice=${build_choice,,}

    case $build_choice in
        1)
            all_paths=("$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT" $(get_active_pkg_collections))
            run_build "All" "${all_paths[@]}"
            ;;
        2)
            run_build "Workspace ($ROS_DEV_WORKSPACE)" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE"
            ;;
        3)
            run_build "Robot ($ROS_DEV_ROBOT)" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT"
            ;;
        4)
            active_pkgs=($(get_active_pkg_collections))
            run_build "Enabled Packages" "${active_pkgs[@]}"
            ;;
        9)  delete_build_folders ;;
        0)  change_build_setting ;;
        q)  break ;;
        *)  echo -e "$BASH_LOG_ERROR Invalid choice." ;;
    esac
done
