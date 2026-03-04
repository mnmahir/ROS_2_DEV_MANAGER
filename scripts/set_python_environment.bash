#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

# Check if ROS_PRIMARY_PYTHON_ENV_NAME is set and not empty
if [ -z "$ROS_PRIMARY_PYTHON_ENV_NAME" ]; then
    echo -e "$BASH_LOG_INFO ROS_PRIMARY_PYTHON_ENV_NAME is not set or empty. Using system Python environment."
    return 0
fi

VENV_BASE_DIR="$ROS_DEV_PACKAGE_DIR/pyenv"
VENV_DIR="$VENV_BASE_DIR/$ROS_PRIMARY_PYTHON_ENV_NAME"

# Check if the environment already exists
if [ ! -d "$VENV_DIR" ]; then
    echo -e "$BASH_LOG_INFO Python virtual environment '$ROS_PRIMARY_PYTHON_ENV_NAME' not found. Creating it at $VENV_DIR..."
    
    # Ensure base directory exists
    mkdir -p "$VENV_BASE_DIR"
    
    # Create the virtual environment with access to system site-packages (critical for ROS 2 like rclpy)
    python3 -m venv --system-site-packages "$VENV_DIR"
    
    if [ $? -eq 0 ]; then
        echo -e "$BASH_LOG_SUCCESS Successfully created Python virtual environment."
        target_activate="$VENV_DIR/bin/activate"
    else
        echo -e "$BASH_LOG_ERROR Failed to create Python virtual environment. Do you have python3-venv installed?"
        return 1
    fi
else
    echo -e "$BASH_LOG_INFO Python virtual environment '$ROS_PRIMARY_PYTHON_ENV_NAME' already exists."
fi

# Activate the virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    echo -e "$BASH_LOG_INFO Activating Python virtual environment '$ROS_PRIMARY_PYTHON_ENV_NAME'..."
    source "$VENV_DIR/bin/activate"
    
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo -e "$BASH_LOG_SUCCESS Python virtual environment activated."
    else
        echo -e "$BASH_LOG_ERROR Failed to activate Python virtual environment."
    fi
else
    echo -e "$BASH_LOG_ERROR Activation script not found at $VENV_DIR/bin/activate. Environment might be corrupted."
fi
