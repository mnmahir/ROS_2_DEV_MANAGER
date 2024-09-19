#!/bin/bash
if [ "$RMW_IMPLEMENTATION" == "rmw_cyclonedds_cpp" ]; then
	if [ -z "$CYCLONEDDS_URI" ]; then
		echo -e "$BASH_INFO Currently using default CycloneDDS configuration. You may set CYCLONEDDS_URI in local_settings.bash to use custom configuration."
	else
		echo -e "$BASH_INFO CYCLONEDDS_URI: \e[33m$CYCLONEDDS_URI\e[0m"
	fi
fi