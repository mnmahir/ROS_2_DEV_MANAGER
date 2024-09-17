if [ "$RMW_IMPLEMENTATION" == "rmw_cyclonedds_cpp" ]; then
	export CYCLONEDDS_URI="$WS_PROJECT_REPO/config/DDS/cyclonedds_default.xml"
fi