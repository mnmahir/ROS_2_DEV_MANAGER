#######################
# Install apt packages
#######################
function install_apt_packages() {
    if [ ${#LIST_APT_PKG[@]} -eq 0 ]
    then
        echo -e "$BASH_INFO No apt packages to install. Skipping..."
    else
        echo -e "$BASH_INFO Installing apt packages..."
        for pkg in "${LIST_APT_PKG[@]}"; do
            sudo apt install $pkg -y
        done
        r2sros
    fi
}


#######################
# Install Python packages
#######################
function install_python_packages() {
    if [ ${#LIST_PYTHON_PKG[@]} -eq 0 ]
    then
        echo -e "$BASH_INFO No Python packages to install. Skipping..."
    else
        echo -e "$BASH_INFO Installing Python packages..."
        for pkg in "${LIST_PYTHON_PKG[@]}"; do
            pip3 install $pkg
        done
        r2ps
    fi
}


#######################
# Clone git packages
#######################
function clone_git_packages() {
    if [ ${#LIST_GIT_REPO[@]} -eq 0 ]
    then
        echo -e "$BASH_INFO No git packages to clone. Skipping..."
    else
        echo -e "$BASH_INFO Cloning git packages..."
        # Create src directory if not exist
        mkdir -p $SRC_DIR
        cd $SRC_DIR
        for repo in "${LIST_GIT_REPO[@]}"; do
            IFS=' ' read -r -a array <<< "$repo"
            git_clone ${array[0]} ${array[1]}
        done
        cd $CURRENT_TERMINAL_DIR
    fi
}


#######################
# Execute commands
#######################
function execute_commands() {
    if [ ${#LIST_EXEC_CMD[@]} -eq 0 ]
    then
        echo -e "$BASH_INFO No commands to execute. Skipping..."
    else
        echo -e "$BASH_INFO Executing commands..."
        for cmd in "${LIST_EXEC_CMD[@]}"; do
            echo -e "$BASH_INFO Executing: \e[36m$cmd\e[0m"
            $cmd
        done
    fi
}