#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

# Configuration and State
LOCAL_BUILD_SETTING="$ROS_DEV_MANAGER_DIR/local/colcon_build_setting.bash"

# Initialize local build setting if missing
if [ ! -f "$LOCAL_BUILD_SETTING" ]; then
    mkdir -p "$(dirname "$LOCAL_BUILD_SETTING")"
    echo "COLCON_BUILD_MODE=0" > "$LOCAL_BUILD_SETTING"
    echo "COLCON_BUILD_PATH_MODE=0" >> "$LOCAL_BUILD_SETTING"
fi

# Ensure legacy installations get the new parameter appended
if ! grep -q "COLCON_BUILD_PATH_MODE" "$LOCAL_BUILD_SETTING"; then
    echo "COLCON_BUILD_PATH_MODE=0" >> "$LOCAL_BUILD_SETTING"
fi

source "$LOCAL_BUILD_SETTING"

# Ensure colcon log outputs to the correct directory if centralized
if [ "$COLCON_BUILD_PATH_MODE" == "1" ]; then
    export COLCON_LOG_PATH="$ROS_PRIMARY_BUILD_PATH/log"
else
    unset COLCON_LOG_PATH
fi

# Helpers
get_active_pkg_collections() {
    local collections=()
    if [ -d "$ROS_DEV_PACKAGE_DIR" ]; then
        while IFS= read -r -d '' list_file; do
            local d
            d=$(dirname "$list_file")
            local base_name
            base_name=$(basename "$d")

            if [[ "$base_name" != _* ]]; then
                continue
            fi

            local is_ignored
            is_ignored=$(bash -c 'source "$1" && echo "$PKG_IGNORE"' _ "$list_file")
            if [ "${is_ignored,,}" != "true" ]; then
                collections+=("$d")
            fi
        done < <(find "$ROS_DEV_PACKAGE_DIR" -mindepth 2 -type f -name pkg_list.bash -print0 | sort -z)
    fi
    echo "${collections[@]}"
}

get_build_command() {
    local base_paths=("$@")
    
    local cmd="colcon build"
    
    if [ "$COLCON_BUILD_PATH_MODE" == "1" ]; then
        cmd="$cmd --build-base $ROS_PRIMARY_BUILD_PATH/build --install-base $ROS_PRIMARY_BUILD_PATH/install"
    fi
    
    if [ ${#base_paths[@]} -gt 0 ]; then
        cmd="$cmd --base-paths ${base_paths[*]}"
    fi

    # Append mode flags
    if [ "$COLCON_BUILD_MODE" == "1" ]; then
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
    
    if [ "$COLCON_BUILD_PATH_MODE" == "1" ]; then
        local cmd=$(get_build_command "${paths[@]}")
        echo -e "$BASH_LOG_INFO Command: \e[33m$cmd\e[0m"
        
        # Execute build
        if eval "$cmd"; then
            local setup_script="$ROS_PRIMARY_BUILD_PATH/install/setup.bash"
            if [ -f "$setup_script" ]; then
                source "$setup_script"
                echo -e "$BASH_LOG_SUCCESS Sourced setup environment: \e[36m$setup_script\e[0m"
            fi
        else
            echo -e "\n$BASH_LOG_ERROR Build failed."
        fi
    else
        # Modular mode: build each path in its own directory
        local ws_paths=()
        local rb_paths=()
        local pkg_paths=()
        for p in "${paths[@]}"; do
            if [[ "$p" == "$ROS_DEV_PACKAGE_DIR/"* ]]; then
                pkg_paths+=("$p")
            elif [[ "$p" == "$ROS_DEV_ROBOT_DIR/"* ]]; then
                rb_paths+=("$p")
            elif [[ "$p" == "$ROS_DEV_WORKSPACE_DIR/"* ]]; then
                ws_paths+=("$p")
            fi
        done
        
        local success=1
        
        if [ ${#pkg_paths[@]} -gt 0 ]; then
            echo -e "\n$BASH_LOG_INFO Modular Build packages target: \e[36m$ROS_DEV_PACKAGE_DIR\e[0m"
            local cmd=$(get_build_command "${pkg_paths[@]}")
            echo -e "$BASH_LOG_INFO Command: \e[33m$cmd\e[0m"
            if (cd "$ROS_DEV_PACKAGE_DIR" && eval "$cmd"); then
                local setup_script="$ROS_DEV_PACKAGE_DIR/install/setup.bash"
                if [ -f "$setup_script" ]; then
                    source "$setup_script"
                    echo -e "$BASH_LOG_SUCCESS Sourced setup environment: \e[36m$setup_script\e[0m"
                fi
            else
                echo -e "$BASH_LOG_ERROR Build failed for packages."
                success=0
            fi
        fi
        
        for p in "${rb_paths[@]}"; do
            echo -e "\n$BASH_LOG_INFO Modular Build robot target: \e[36m$p\e[0m"
            local cmd=$(get_build_command "$p")
            echo -e "$BASH_LOG_INFO Command: \e[33m$cmd\e[0m"
            if (cd "$p" && eval "$cmd"); then
                local setup_script="$p/install/setup.bash"
                if [ -f "$setup_script" ]; then
                    source "$setup_script"
                    echo -e "$BASH_LOG_SUCCESS Sourced setup environment: \e[36m$setup_script\e[0m"
                fi
            else
                echo -e "$BASH_LOG_ERROR Build failed for $p."
                success=0
            fi
        done
        
        for p in "${ws_paths[@]}"; do
            echo -e "\n$BASH_LOG_INFO Modular Build workspace target: \e[36m$p\e[0m"
            local cmd=$(get_build_command "$p")
            echo -e "$BASH_LOG_INFO Command: \e[33m$cmd\e[0m"
            if (cd "$p" && eval "$cmd"); then
                local setup_script="$p/install/setup.bash"
                if [ -f "$setup_script" ]; then
                    source "$setup_script"
                    echo -e "$BASH_LOG_SUCCESS Sourced setup environment: \e[36m$setup_script\e[0m"
                fi
            else
                echo -e "$BASH_LOG_ERROR Build failed for $p."
                success=0
            fi
        done
        
        if [ $success -eq 0 ]; then
            echo -e "\n$BASH_LOG_ERROR One or more builds failed."
        fi
    fi
}

delete_build_folders() {
    echo -e "\n\e[33m===== Delete Build Directories =====\e[0m"
    local changed=0
    if [ "$COLCON_BUILD_PATH_MODE" == "1" ]; then
        local build_dir="$ROS_PRIMARY_BUILD_PATH/build"
        local install_dir="$ROS_PRIMARY_BUILD_PATH/install"
        local log_dir="$ROS_PRIMARY_BUILD_PATH/log"

        if [ -d "$build_dir" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete build folder ($build_dir)? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$build_dir"
                echo -e "$BASH_LOG_SUCCESS Deleted $build_dir"
                changed=1
            fi
        fi

        if [ -d "$install_dir" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete install folder ($install_dir)? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$install_dir"
                echo -e "$BASH_LOG_SUCCESS Deleted $install_dir"
                changed=1
            fi
        fi

        if [ -d "$log_dir" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete log folder ($log_dir)? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$log_dir"
                echo -e "$BASH_LOG_SUCCESS Deleted $log_dir"
                changed=1
            fi
        fi
    else
        echo -e "$BASH_LOG_INFO Modular mode active. The \e[31mbuild/\e[0m, \e[31minstall/\e[0m, and \e[31mlog/\e[0m folders will be deleted. Choose dir:"
        echo -e "[\e[36m1\e[0m] ALL"
        echo -e "[\e[36m2\e[0m] Workspace only - \e[31mws/$ROS_DEV_WORKSPACE\e[0m"
        
        if [ -n "$ROS_DEV_ROBOT" ]; then
            echo -e "[\e[36m3\e[0m] Robot only - \e[31mrb/$ROS_DEV_ROBOT\e[0m"
        else
            echo -e "[\e[36m3\e[0m] Robot only - \e[31mNone selected\e[0m"
        fi
        
        echo -e "[\e[36m4\e[0m] Packages only - \e[31mpkg\e[0m"
        echo -e "[\e[36mQ\e[0m] Cancel"
        echo -n -e "$BASH_LOG_ACTION Select folders to delete: "
        read del_choice
        del_choice=${del_choice,,}

        if [ "$del_choice" == "q" ]; then
            return 0
        elif [ "$del_choice" == "1" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete ALL modular build folders? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/build" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/install" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/log"
                if [ -n "$ROS_DEV_ROBOT" ]; then
                    rm -rf "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/build" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/install" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/log"
                fi
                rm -rf "$ROS_DEV_PACKAGE_DIR/build" "$ROS_DEV_PACKAGE_DIR/install" "$ROS_DEV_PACKAGE_DIR/log"
                echo -e "$BASH_LOG_SUCCESS Deleted ALL modular build outputs."
                changed=1
            fi
        elif [ "$del_choice" == "2" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete Workspace modular build folders? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/build" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/install" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE/log"
                echo -e "$BASH_LOG_SUCCESS Deleted Workspace build outputs."
                changed=1
            fi
        elif [ "$del_choice" == "3" ]; then
            if [ -n "$ROS_DEV_ROBOT" ]; then
                echo -n -e "$BASH_LOG_ACTION Delete Robot modular build folders? (y/N): "
                read ans
                if [[ "${ans,,}" == "y" ]]; then
                    rm -rf "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/build" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/install" "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT/log"
                    echo -e "$BASH_LOG_SUCCESS Deleted Robot build outputs."
                    changed=1
                fi
            else
                echo -e "$BASH_LOG_WARNING No active robot selected."
            fi
        elif [ "$del_choice" == "4" ]; then
            echo -n -e "$BASH_LOG_ACTION Delete Package modular build folders? (y/N): "
            read ans
            if [[ "${ans,,}" == "y" ]]; then
                rm -rf "$ROS_DEV_PACKAGE_DIR/build" "$ROS_DEV_PACKAGE_DIR/install" "$ROS_DEV_PACKAGE_DIR/log"
                echo -e "$BASH_LOG_SUCCESS Deleted Packages build outputs."
                changed=1
            fi
        else
            echo -e "$BASH_LOG_ERROR Invalid choice."
        fi
    fi
    
    if [ "$changed" -eq 1 ]; then
        echo -e "\n$BASH_LOG_INFO Reloading terminal to clear sourced environment..."
        exec bash
    fi
}

change_build_setting() {
    echo -e "\n\e[33m===== Change Build Setting =====\e[0m"
    echo -e "\e[36m[Type]\e[0m"
    echo -e "  [\e[36m1\e[0m] Basic (e.g. colcon build --symlink-install) -> \e[33m(Sets to 0)\e[0m"
    echo -e "  [\e[36m2\e[0m] Release (e.g. colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release) -> \e[33m(Sets to 1)\e[0m"
    echo -e "\e[36m[Path Mode]\e[0m"
    echo -e "  [\e[36m3\e[0m] Modular (output to individual directories) -> \e[33m(Sets to 0)\e[0m"
    echo -e "  [\e[36m4\e[0m] Centralized (output to ROS_OUTPUT_DIR) -> \e[33m(Sets to 1)\e[0m"
    echo -e "[\e[36mQ\e[0m] Cancel"
    echo -e "\e[33m================================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select setting: "
    read mode_choice
    mode_choice=${mode_choice,,}
    
    local changed=0
    if [ "$mode_choice" == "q" ]; then
        return 0
    elif [[ "$mode_choice" == "1" ]]; then
        sed -i "s/^COLCON_BUILD_MODE=.*/COLCON_BUILD_MODE=0/" "$LOCAL_BUILD_SETTING"
        export COLCON_BUILD_MODE=0
        echo -e "$BASH_LOG_SUCCESS Build Type setting updated to Basic (0)."
    elif [[ "$mode_choice" == "2" ]]; then
        sed -i "s/^COLCON_BUILD_MODE=.*/COLCON_BUILD_MODE=1/" "$LOCAL_BUILD_SETTING"
        export COLCON_BUILD_MODE=1
        echo -e "$BASH_LOG_SUCCESS Build Type setting updated to Release (1)."
    elif [[ "$mode_choice" == "3" ]]; then
        sed -i "s/^COLCON_BUILD_PATH_MODE=.*/COLCON_BUILD_PATH_MODE=0/" "$LOCAL_BUILD_SETTING"
        export COLCON_BUILD_PATH_MODE=0
        changed=1
        echo -e "$BASH_LOG_SUCCESS Build Path Mode set to Modular."
    elif [[ "$mode_choice" == "4" ]]; then
        sed -i "s/^COLCON_BUILD_PATH_MODE=.*/COLCON_BUILD_PATH_MODE=1/" "$LOCAL_BUILD_SETTING"
        export COLCON_BUILD_PATH_MODE=1
        changed=1
        echo -e "$BASH_LOG_SUCCESS Build Path Mode set to Centralized."
    else
        echo -e "$BASH_LOG_ERROR Invalid choice. Setting unchanged."
    fi
    
    if [ "$changed" -eq 1 ]; then
        echo -e "$BASH_LOG_INFO Reloading terminal to apply path changes..."
        exec bash
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
    if [ "$COLCON_BUILD_MODE" == "1" ]; then
        mode_str="Release"
    fi
    
    path_mode_str="Modular"
    if [ "$COLCON_BUILD_PATH_MODE" == "1" ]; then
        path_mode_str="Centralized"
    fi

    echo -e "\n\e[33m===== Smart Colcon Build =====\e[0m"
    echo -e "[\e[36m1\e[0m] Build all"
    echo -e "[\e[36m2\e[0m] Build workspace only \e[36m(r2bws)\e[0m - \e[33mws/$ROS_DEV_WORKSPACE\e[0m"
    echo -e "[\e[36m3\e[0m] Build robot only \e[36m(r2brb)\e[0m - \e[33mrb/$ROS_DEV_ROBOT\e[0m"
    echo -e "[\e[36m4\e[0m] Build enabled pkg only \e[36m(r2bpkg)\e[0m - \e[33mpkg\e[0m"
    echo -e "[\e[36m9\e[0m] Delete build, install & log folder \e[36m(r2bdel)\e[0m"
    echo -e "[\e[36m0\e[0m] Change build setting"
    echo -e "[\e[36mQ\e[0m] Exit"
    echo -e "\e[33m==============================\e[0m"
    echo -e "Build type: \e[32m($COLCON_BUILD_MODE) $mode_str\e[0m"
    echo -e "Path mode: \e[32m($COLCON_BUILD_PATH_MODE) $path_mode_str\e[0m"
    echo -e "\e[33m==============================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read build_choice
    
    build_choice=${build_choice,,}

    case $build_choice in
        1)
            all_paths=($(get_active_pkg_collections) "$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT" "$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE")
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
