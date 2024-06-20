#!/bin/bash
# Author: Mahir Sehmi
# Date: 2024-05-16
# Usage: Make sure to source dev_init.bash first before running this script.

# To check if dev_init.bash has been sourced.
if [[ $WS_DEV_SESSION_CHECK == "" ]] || [[ $WS_DEV_SESSION_CHECK != 1 ]]  
then
 echo -e "$BASH_ERROR Make sure dev_init.bash is sourced. Refer to README.md for instructions."
 echo -e "$BASH_ACTION PRESS [ENTER] TO EXIT"
 read
 exit 0
fi

BASH_TOTAL_COUNT=0
BASH_SUCCESS_COUNT=0
BASH_ERROR_COUNT=0
BASH_WARNING_COUNT=0

SOURCE_LIST=()

source $WS_DEV_MANAGER_DIR/scripts/func_source_file.bash
source $WS_PROJECT_REPO/config/source_list.bash
echo -e "$BASH_INFO Sourcing files"


# Loop through all item in SOURCE_LIST and source them.
for i in "${SOURCE_LIST[@]}"
do
    source_file $i
done
# =====================================

echo -e "$BASH_INFO Successfully sourced $BASH_SUCCESS_COUNT/$BASH_TOTAL_COUNT file(s)."
if [[ $BASH_WARNING_COUNT -gt 0 ]]; then
    echo -e "$BASH_WARNING Unable to source $BASH_WARNING_COUNT file(s). Program depending on this source may fail. Check if they are installed correctly or wrong path provided."
fi
echo -e "$BASH_INFO Done sourcing."
