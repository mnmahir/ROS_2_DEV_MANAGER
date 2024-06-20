function source_file {
    FILE=$1
    if [ -f "$FILE" ]; then
        source $FILE
        echo -e "$BASH_SUCCESS Sourced \e[36m$FILE\e[0m."
        ((BASH_TOTAL_COUNT++))
        ((BASH_SUCCESS_COUNT++))
        else
        ((BASH_TOTAL_COUNT++))
        ((BASH_WARNING_COUNT++))
        echo -e "$BASH_WARNING Source failed. Can't find \e[36m$FILE\e[0m."
    fi
}