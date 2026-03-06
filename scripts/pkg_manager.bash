#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

# --- Helper Functions ---

# Function to get active pkg collections (excluding hidden ones)
get_active_pkg_collections() {
    local collections=()
    for d in "$ROS_DEV_PACKAGE_DIR"/_*; do
        if [ -d "$d" ] && [ -f "$d/pkg_list.bash" ]; then
            # Source script in a subshell to safely read PKG_IGNORE
            local is_ignored=$(bash -c "source \"$d/pkg_list.bash\" && echo \$PKG_IGNORE")
            # If not precisely True, we consider it visible/active
            if [ "${is_ignored,,}" != "true" ]; then
                collections+=("$d")
            fi
        fi
    done
    echo "${collections[@]}"
}

# Function to get ALL pkg collections (including hidden ones)
get_all_pkg_collections() {
    local collections=()
    for d in "$ROS_DEV_PACKAGE_DIR"/_*; do
        if [ -d "$d" ] && [ -f "$d/pkg_list.bash" ]; then
            collections+=("$d")
        fi
    done
    echo "${collections[@]}"
}

# Ask path selection for operations
# Returns paths in array PATHS_TO_PROCESS
ask_path_selection() {
    local operation_name=$1
    echo -e "\n\e[33m===== Package Manager - Select Path =====\e[0m"
    echo -e "[\e[36m1\e[0m] All"
    echo -e "[\e[36m2\e[0m] Workspace only - $ROS_DEV_WORKSPACE"
    echo -e "[\e[36m3\e[0m] Robot only - $ROS_DEV_ROBOT"
    echo -e "[\e[36m4\e[0m] All of visible pkg collection - pkg"
    echo -e "[\e[36m5\e[0m] Selected visible pkg collection only - pkg/_XXXX"
    echo -e "[\e[36mQ\e[0m] Cancel"
    echo -e "\e[33m=========================================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read path_choice
    path_choice=${path_choice,,}

    if [ "$path_choice" == "q" ]; then
        return 1
    fi

    PATHS_TO_PROCESS=()
    
    local ws_path="$ROS_DEV_WORKSPACE_DIR/$ROS_DEV_WORKSPACE"
    local rb_path="$ROS_DEV_ROBOT_DIR/$ROS_DEV_ROBOT"
    local active_collections=($(get_active_pkg_collections))

    case $path_choice in
        1)
            PATHS_TO_PROCESS+=("$ws_path" "$rb_path" "${active_collections[@]}")
            ;;
        2)
            PATHS_TO_PROCESS+=("$ws_path")
            ;;
        3)
            PATHS_TO_PROCESS+=("$rb_path")
            ;;
        4)
            PATHS_TO_PROCESS+=("${active_collections[@]}")
            ;;
        5)
            if [ ${#active_collections[@]} -eq 0 ]; then
                echo -e "$BASH_LOG_WARNING No visible package collections found in $ROS_DEV_PACKAGE_DIR."
                return 1
            fi
            echo -e "\n\e[33m===== Select Visible Pkg Collection =====\e[0m"
            local idx=1
            for coll in "${active_collections[@]}"; do
                local cname=$(basename "$coll")
                echo -e "[\e[36m$idx\e[0m] $cname"
                ((idx++))
            done
            echo -e "[\e[36mQ\e[0m] Cancel"
            echo -e "\e[33m=========================================\e[0m"
            echo -n -e "$BASH_LOG_ACTION Select collection: "
            read coll_choice
            coll_choice=${coll_choice,,}
            if [ "$coll_choice" == "q" ]; then return 1; fi
            if [[ "$coll_choice" =~ ^[0-9]+$ ]] && [ "$coll_choice" -ge 1 ] && [ "$coll_choice" -le ${#active_collections[@]} ]; then
                PATHS_TO_PROCESS+=("${active_collections[$((coll_choice-1))]}")
            else
                echo -e "$BASH_LOG_ERROR Invalid choice."
                return 1
            fi
            ;;
        *)
            echo -e "$BASH_LOG_ERROR Invalid choice."
            return 1
            ;;
    esac

    # Validate paths have pkg_list.bash
    local valid_paths=()
    for p in "${PATHS_TO_PROCESS[@]}"; do
        if [ -f "$p/pkg_list.bash" ]; then
            valid_paths+=("$p")
        fi
    done
    PATHS_TO_PROCESS=("${valid_paths[@]}")

    if [ ${#PATHS_TO_PROCESS[@]} -eq 0 ]; then
        echo -e "$BASH_LOG_WARNING Selected paths do not contain a pkg_list.bash file."
        return 1
    fi

    echo -e "\n$BASH_LOG_INFO Operation: $operation_name"
    echo -e "$BASH_LOG_INFO Target directories for this operation:"
    for p in "${PATHS_TO_PROCESS[@]}"; do
        echo -e "  - \e[36m$p\e[0m"
    done

    echo -n -e "$BASH_LOG_ACTION Do you want to proceed? (y/N): "
    read confirm
    if [[ "${confirm,,}" != "y" ]]; then
        echo -e "$BASH_LOG_INFO Operation aborted."
        return 1
    fi

    return 0
}

# --- Core Operations ---

do_git_repo() {
    local git_action=$1
    shift
    local paths=("$@")

    for p in "${paths[@]}"; do
        echo -e "\n$BASH_LOG_INFO \e[33mProcessing Git repos in $p...\e[0m"
        
        # Reset lists just in case
        LIST_GIT_REPO=()
        source "$p/pkg_list.bash"

        local src_dir="$p/src"
        if [ ! -d "$src_dir" ]; then
            mkdir -p "$src_dir"
        fi

        for entry in "${LIST_GIT_REPO[@]}"; do
            # Format is "Git URL" "Commit ID/Tag/Branch"
            local url=$(echo "$entry" | awk '{print $1}')
            local tag=$(echo "$entry" | awk '{print $2}')
            
            # Simple repo name extraction from URL
            local repo_name=$(basename "$url" .git)
            local target_dir="$src_dir/$repo_name"
            
            echo -e "$BASH_LOG_INFO   -> Repo: $repo_name"
            
            if [ "$git_action" == "clone" ]; then
                if [ ! -d "$target_dir" ]; then
                    if [ -n "$tag" ]; then
                        echo -e "$BASH_LOG_INFO      Running: git clone $url $target_dir"
                        git clone "$url" "$target_dir"
                        echo -e "$BASH_LOG_INFO      Checking out $tag and initializing submodules"
                        (cd "$target_dir" && git checkout "$tag" && git submodule update --init --recursive)
                    else
                        echo -e "$BASH_LOG_INFO      Running: git clone --recurse-submodules $url $target_dir"
                        git clone --recurse-submodules "$url" "$target_dir"
                    fi
                else
                    echo -e "$BASH_LOG_INFO      Repo already exists at $target_dir. Skipping clone."
                fi
            elif [ "$git_action" == "fetch" ]; then
                if [ -d "$target_dir" ]; then
                    echo -e "$BASH_LOG_INFO      Running: git fetch (incl submodules)"
                    (cd "$target_dir" && git fetch --all && git submodule foreach git fetch --all)
                fi
            elif [ "$git_action" == "pull" ]; then
                 if [ -d "$target_dir" ]; then
                    echo -e "$BASH_LOG_INFO      Running: git pull (incl submodules)"
                    (cd "$target_dir" && git pull && git submodule update --init --recursive)
                 fi
            elif [ "$git_action" == "force_pull" ]; then
                if [ -d "$target_dir" ]; then
                    echo -e "$BASH_LOG_INFO      Running: force git pull"
                    # Reset hard to origin/HEAD
                    (cd "$target_dir" && git fetch --all && git reset --hard @{u} && git clean -fd && git submodule update --init --recursive --force)
                fi
            fi
        done
    done
}

do_apt_pkg() {
    local paths=("$@")
    local all_apt_pkgs=()

    for p in "${paths[@]}"; do
        LIST_APT_PKG=()
        source "$p/pkg_list.bash"
        for pkg in "${LIST_APT_PKG[@]}"; do
            # Extract just the package names handling --optional-flag logic if needed
            local pkg_name=$(echo "$pkg" | awk '{print $1}')
            all_apt_pkgs+=("$pkg_name")
        done
    done

    if [ ${#all_apt_pkgs[@]} -gt 0 ]; then
        echo -e "\n$BASH_LOG_INFO Preparing to install APT packages..."
        echo -e "$BASH_LOG_INFO Running: sudo apt update"
        sudo apt update
        echo -e "$BASH_LOG_INFO Running: sudo apt install -y ${all_apt_pkgs[*]}"
        sudo apt install -y "${all_apt_pkgs[@]}"
    else
        echo -e "\n$BASH_LOG_INFO No APT packages defined in selected paths."
    fi
}

do_python_pkg() {
    local paths=("$@")
    local all_py_pkgs=()

    for p in "${paths[@]}"; do
        LIST_PYTHON_PKG=()
        source "$p/pkg_list.bash"
        for pkg in "${LIST_PYTHON_PKG[@]}"; do
            local pkg_name=$(echo "$pkg" | awk '{print $1}')
            all_py_pkgs+=("$pkg_name")
        done
    done

    if [ ${#all_py_pkgs[@]} -gt 0 ]; then
        # Ensure we are currently in our ROS Python env if one exists
        if [ "$VIRTUAL_ENV" == "" ] && [ -n "$ROS_PRIMARY_PYTHON_ENV_NAME" ]; then
            local venv_activate="$ROS_DEV_PACKAGE_DIR/pyenv/$ROS_PRIMARY_PYTHON_ENV_NAME/bin/activate"
            if [ -f "$venv_activate" ]; then
                source "$venv_activate"
            fi
        fi

        echo -e "\n$BASH_LOG_INFO Preparing to install Python packages via pip..."
        echo -e "$BASH_LOG_INFO Running: python3 -m pip install ${all_py_pkgs[*]}"
        python3 -m pip install "${all_py_pkgs[@]}"
    else
        echo -e "\n$BASH_LOG_INFO No Python packages defined in selected paths."
    fi
}

do_rosdep() {
    local paths=("$@")
    echo -e "\n$BASH_LOG_INFO Processing rosdep for selected paths..."
    
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        echo -e "$BASH_LOG_INFO Initializing rosdep..."
        sudo rosdep init
    fi

    echo -e "$BASH_LOG_INFO Running: rosdep update"
    rosdep update

    local src_paths=()
    for p in "${paths[@]}"; do
        if [ -d "$p/src" ]; then
             src_paths+=("$p/src")
        fi
    done

    if [ ${#src_paths[@]} -gt 0 ]; then
        local target_srcs="${src_paths[*]}"
        echo -e "$BASH_LOG_INFO Running: rosdep install -y -r -q --from-paths $target_srcs --ignore-src --rosdistro $ROS_DISTRO"
        rosdep install -y -r -q --from-paths "${src_paths[@]}" --ignore-src --rosdistro "$ROS_DISTRO"
    else
        echo -e "\n$BASH_LOG_INFO No src/ directories found in selected paths to process rosdep."
    fi
}

do_exec_cmd() {
    local mode=$1 # "pre" or "post"
    local paths=("${@:2}")

    for p in "${paths[@]}"; do
        LIST_EXEC_CMD_PRE=()
        LIST_EXEC_CMD_POST=()
        source "$p/pkg_list.bash"

        local cmds=()
        if [ "$mode" == "pre" ]; then
            cmds=("${LIST_EXEC_CMD_PRE[@]}")
        else
            cmds=("${LIST_EXEC_CMD_POST[@]}")
        fi

        if [ ${#cmds[@]} -gt 0 ]; then
            echo -e "\n$BASH_LOG_INFO Executing $mode commands in \e[36m$p\e[0m..."
            for cmd in "${cmds[@]}"; do
                echo -e "$BASH_LOG_INFO Running: $cmd"
                (cd "$p" && eval "$cmd")
            done
        fi
    done
}

manage_collections_visibility() {
    while true; do
        local all_collections=($(get_all_pkg_collections))
        if [ ${#all_collections[@]} -eq 0 ]; then
            echo -e "$BASH_LOG_WARNING No package collections found in $ROS_DEV_PACKAGE_DIR."
            return
        fi

        echo -e "\n\e[33m===== Hide/Unhide Pkg Collections =====\e[0m"
        local idx=1
        for coll in "${all_collections[@]}"; do
            local cname=$(basename "$coll")
            local is_ignored=$(bash -c "source \"$coll/pkg_list.bash\" && echo \$PKG_IGNORE")
            
            if [ "${is_ignored,,}" == "true" ]; then
                echo -e "[\e[36m$idx\e[0m] \e[31m$cname (Hidden)\e[0m"
            else
                echo -e "[\e[36m$idx\e[0m] \e[32m$cname (Visible)\e[0m"
            fi
            ((idx++))
        done
        echo -e "[\e[36mQ\e[0m] Back to Main Menu"
        echo -e "\e[33m=======================================\e[0m"
        echo -n -e "$BASH_LOG_ACTION Select collection to toggle: "
        read toggle_choice
        toggle_choice=${toggle_choice,,}

        if [ "$toggle_choice" == "q" ]; then
            break
        elif [[ "$toggle_choice" =~ ^[0-9]+$ ]] && [ "$toggle_choice" -ge 1 ] && [ "$toggle_choice" -le ${#all_collections[@]} ]; then
            local target_coll="${all_collections[$((toggle_choice-1))]}"
            local list_file="$target_coll/pkg_list.bash"
            
            local current=$(bash -c "source \"$list_file\" && echo \$PKG_IGNORE")
            if [ "${current,,}" == "true" ]; then
                # Change to false
                sed -i 's/PKG_IGNORE=.*[Tt]rue.*/PKG_IGNORE=False/' "$list_file"
                echo -e "$BASH_LOG_SUCCESS Set $target_coll to Visible."
            else
                # Change to true
                sed -i 's/PKG_IGNORE=.*[Ff]alse.*/PKG_IGNORE=True/' "$list_file"
                echo -e "$BASH_LOG_SUCCESS Set $target_coll to Hidden."
            fi
        else
            echo -e "$BASH_LOG_ERROR Invalid choice."
        fi
    done
}

manage_git_menu() {
    if ! ask_path_selection "Manage Git Repository"; then return; fi

    echo -e "\n\e[33m===== Git Repository Operations =====\e[0m"
    echo -e "[\e[36m1\e[0m] git clone - Clones URLs from list. Also clones submodules."
    echo -e "[\e[36m2\e[0m] git fetch - Fetch latest from origin (incl submodules)."
    echo -e "[\e[36m3\e[0m] git pull - Pulls latest from origin (incl submodules)."
    echo -e "[\e[36m4\e[0m] force git pull - Hard reset and force pull replacing local changes."
    echo -e "[\e[36mQ\e[0m] Cancel"
    echo -e "\e[33m=====================================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read git_choice
    git_choice=${git_choice,,}

    case $git_choice in
        1) do_git_repo "clone" "${PATHS_TO_PROCESS[@]}" ;;
        2) do_git_repo "fetch" "${PATHS_TO_PROCESS[@]}" ;;
        3) do_git_repo "pull" "${PATHS_TO_PROCESS[@]}" ;;
        4) do_git_repo "force_pull" "${PATHS_TO_PROCESS[@]}" ;;
        q) return ;;
        *) echo -e "$BASH_LOG_ERROR Invalid choice." ;;
    esac
}

execute_cmd_menu() {
    if ! ask_path_selection "Execute commands"; then return; fi

    echo -e "\n\e[33m===== Execute Commands =====\e[0m"
    echo -e "[\e[36m1\e[0m] Run PRE-installation commands (LIST_EXEC_CMD_PRE)"
    echo -e "[\e[36m2\e[0m] Run POST-installation commands (LIST_EXEC_CMD_POST)"
    echo -e "[\e[36mQ\e[0m] Cancel"
    echo -e "\e[33m====================================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read cmd_choice
    cmd_choice=${cmd_choice,,}

    case $cmd_choice in
        1) do_exec_cmd "pre" "${PATHS_TO_PROCESS[@]}" ;;
        2) do_exec_cmd "post" "${PATHS_TO_PROCESS[@]}" ;;
        q) return ;;
        *) echo -e "$BASH_LOG_ERROR Invalid choice." ;;
    esac
}

# --- Main Menu Loop ---

while true; do
    echo -e "\n\e[33m===== Package Manager =====\e[0m"
    echo -e "[\e[36m1\e[0m] One Push - Run Git Clone > APT Install > Pip > Rosdep > Cmds."
    echo -e "[\e[36m2\e[0m] Manage Git Repository."
    echo -e "[\e[36m3\e[0m] Install APT Packages."
    echo -e "[\e[36m4\e[0m] Install Python Packages."
    echo -e "[\e[36m5\e[0m] Rosdep update & install."
    echo -e "[\e[36m6\e[0m] Execute command."
    echo -e "[\e[36m0\e[0m] Hide/unhide pkg collections."
    echo -e "[\e[36mQ\e[0m] Exit"
    echo -e "\e[33m===========================\e[0m"
    echo -n -e "$BASH_LOG_ACTION Select an option: "
    read main_choice

    # Lowercase choice for exit
    main_choice=${main_choice,,}

    case $main_choice in
        1)
            if ask_path_selection "One Push (Clone > APT > Python > Rosdep > PostCmds)"; then
                do_exec_cmd "pre" "${PATHS_TO_PROCESS[@]}"
                do_git_repo "clone" "${PATHS_TO_PROCESS[@]}"
                do_apt_pkg "${PATHS_TO_PROCESS[@]}"
                do_python_pkg "${PATHS_TO_PROCESS[@]}"
                do_rosdep "${PATHS_TO_PROCESS[@]}"
                do_exec_cmd "post" "${PATHS_TO_PROCESS[@]}"
            fi
            ;;
        2) manage_git_menu ;;
        3) 
            if ask_path_selection "Install APT Packages"; then
                do_apt_pkg "${PATHS_TO_PROCESS[@]}"
            fi
            ;;
        4)
            if ask_path_selection "Install Python Packages"; then
                do_python_pkg "${PATHS_TO_PROCESS[@]}"
            fi
            ;;
        5)
            if ask_path_selection "Rosdep update & install"; then
                do_rosdep "${PATHS_TO_PROCESS[@]}"
            fi
            ;;
        6) execute_cmd_menu ;;
        0) manage_collections_visibility ;;
        q) break ;;
        *) echo -e "$BASH_LOG_ERROR Invalid choice." ;;
    esac
done
