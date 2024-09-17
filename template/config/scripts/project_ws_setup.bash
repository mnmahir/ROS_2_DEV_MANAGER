# Local settings folder creation
if [ ! -d "$WS_PROJECT_REPO/config/local" ]; then
	echo -e "$BASH_INFO Creating local folder in $WS_PROJECT_REPO/config"
	mkdir -p $WS_PROJECT_REPO/config/local
	
fi
if [ ! -f "$WS_PROJECT_REPO/config/local/.gitignore" ]; then
	echo "*" > $WS_PROJECT_REPO/config/local/.gitignore
fi

if [ ! -f "$WS_PROJECT_REPO/config/local/local_settings.bash" ]; then
	cp $WS_PROJECT_REPO/config/scripts/local_settings_to_copy.bash $WS_PROJECT_REPO/config/local/local_settings.bash
fi
