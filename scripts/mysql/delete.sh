#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> MySQL Database Management |> DELETE ]|=-\n"

# * ===========
# * Validation
# * =========

# ? Check if prompt function exists and source it
function_path="./scripts/functions/prompt.sh"
if [[ ! -f $function_path ]]; then
    echo -e "Error: Working directory isn't the script's main; as \"prompt\" function is missing.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $function_path

# ? A function to check for a function existence in order to source it
sourceIfAvailable() {
    local functionNameCamel=$1
    local functionNameSnake=$(echo $1 | sed -r 's/([a-z])([A-Z])/\1_\L\2/g')
    local functionPath="./scripts/functions/${functionNameSnake}.sh"

    if [[ ! -f $functionPath ]]; then
        prompt "Working directory isn't the script's main; as \"${functionNameCamel^}\" function is missing." \
               "Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands."
    else
        source $functionPath
    fi
}

# * Source the necessary functions
sourceIfAvailable "mysqlDown"

# ? Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script."
fi

# ? Confirm if setup script isn't run already
if [ ! -e "$PWD/done-setup.flag" ]; then
    echo -n "Setup script isn't run yet. Are you sure you want to continue? (y/n) "
    read confirmation

    case "$confirmation" in
    n|N|no|No|NO|nope|Nope|NOPE)
        echo -e "\nAborting...\n"

        echo -n "Press any key to continue..."
        read whatever

        clear
        exit 1
        ;;
    esac
fi

# * ============
# * Preparation
# * ==========

# ? Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# ? Set the echoing level
conditional_quiet="--quiet"
cancel_suppression=false
case $LOGGING_LEVEL in
# Notifications Only
1)
    exec 3>&1
    exec > /dev/null 2>&1
    ;;
# Notifications + Errors + Warnings
2)
    exec 3>&1
    exec > /dev/null
    ;;
# Everything
*)
    exec 3>&1
    conditional_quiet=""
    cancel_suppression=true
    ;;
esac

# * ========
# * Process
# * ======

# ? Get the db name
echo -ne "Enter the database name: " >&3
read db_name

# ? Drop the database if it exists
mysqlDown $db_name $DB_PASSWORD

# * ========
# * The End
# * ======

# * Prompt to continue
echo -ne "\nPress any key to continue..." >&3
read whatever

clear >&3
