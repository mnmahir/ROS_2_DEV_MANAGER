#!/bin/bash
if [ "$RMW_IMPLEMENTATION" == "rmw_cyclonedds_cpp" ]; then
	echo -e "$BASH_INFO CYCLONEDDS_URI: \e[33m$CYCLONEDDS_URI\e[0m"
fi