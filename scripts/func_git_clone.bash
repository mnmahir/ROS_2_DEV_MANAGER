function git_clone {
    # NOTE: This function does accept branch, full and short commit SHA value and also tag number assigned to COMMIT_ID to get desired repo.
    #       However, the script is written to echo ERROR or WARNING message if not providing full commit SHA value because
    #       it is comparing the value stored in COMMIT_ID and output of 'git rev-parse HEAD' command.


    URL=$1
    COMMIT_ID=$2
    DIR_REGEX='\/([a-zA-Z0-9._-]+)\.git'
    cd $CLONE_DIR

    if [[ $URL == "" ]]
    then
        echo -e "$BASH_ERROR Invalid URL. Will not clone."
        return
    fi

    echo ""
    echo -e "$BASH_INFO Cloning \e[36m$URL\e[0m at \e[36m$CLONE_DIR\e[0m."
    if [[ $URL =~ $DIR_REGEX ]]
    then
        REPO_DIR_NAME="${BASH_REMATCH[1]}"
        echo -e "$BASH_INFO into '$REPO_DIR_NAME' directory."
        git clone $URL $REPO_DIR_NAME
        
        if [[ $COMMIT_ID != "" ]]
        then
            echo -e "$BASH_INFO Checking out $COMMIT_ID"
            cd $CLONE_DIR/$REPO_DIR_NAME
            git checkout $COMMIT_ID
            if [[ "$COMMIT_ID" = "$(git rev-parse HEAD)" ]] # Check if it is a full commit SHA
            then
                echo -e "$BASH_SUCCESS Successfuly checked out '$COMMIT_ID'."
            elif [[ "$COMMIT_ID" = "$(git describe --tags --abbrev=0)" ]]   # Check if it is a tag
            then
                echo -e "$BASH_SUCCESS Successfuly checked out '$COMMIT_ID'."
            elif [[ "$COMMIT_ID" = "$(git rev-parse --abbrev-ref HEAD)" ]]  # Check if it is a branch
            then
                echo -e "$BASH_SUCCESS Successfuly checked out '$COMMIT_ID'."
            else
                echo -e "$BASH_ERROR Could not find commit SHA '$COMMIT_ID' in '$URL'"
                echo -e "$BASH_WARNING Current HEAD is '$(git rev-parse HEAD)'"
            fi
        else
            echo -e "$BASH_WARNING No commit ID or tag given. Will use latest commit from main branch instead."
        fi
        echo -e "$BASH_SUCCESS Done cloning '$URL'."
    else
        echo -e "$BASH_ERROR Can't clone with proper directory name. Check for typo!"
        echo -e "$BASH_WARNING Will not clone '$URL'"
    fi
    
}