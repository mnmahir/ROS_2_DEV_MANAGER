#!/bin/bash
# Author: Mahir Sehmi
# Date: 2026-03-03

# Source the configuration to load the SOURCE_LIST array
source "$ROS_DEV_MANAGER_DIR/settings/source_list.bash"

BASH_SUCCESS_COUNT=0
BASH_WARNING_COUNT=0
BASH_TOTAL_COUNT=${#SOURCE_LIST[@]}

# Loop through the list of items
for script in "${SOURCE_LIST[@]}"; do
    if [ -f "$script" ]; then
        source "$script"
        ((BASH_SUCCESS_COUNT++))
    else
        echo -e "$BASH_LOG_WARNING Failed to find source file: $script"
        ((BASH_WARNING_COUNT++))
    fi
done

# Output final summary status
echo -e "$BASH_LOG_INFO Successfully sourced $BASH_SUCCESS_COUNT/$BASH_TOTAL_COUNT file(s)."
if [[ $BASH_WARNING_COUNT -gt 0 ]]; then
    echo -e "$BASH_LOG_WARNING Unable to source $BASH_WARNING_COUNT file(s). Program depending on this source may fail. Check if they are built and installed properly or if the path is correct."
fi
