#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> MySQL Database Management |> CREATE ]|=-\n"

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

# ? Get the DB name
echo -ne "Enter the database name: " >&3
read db_name

# ? Escape and format the name
db_name=$(echo "$db_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
db_name=${db_name// /}
db_name=$(echo "$db_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

# ? Create the DB if it doesn't exist
export MYSQL_PWD=$DB_PASSWORD
if mysql -u root -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$db_name'" | grep "$db_name" > /dev/null; then
    echo -e "\nMySQL database '$db_name' already exists!" >&3
else
    mysql -u root -e "CREATE DATABASE $db_name;"
    echo -e "\nCreated '$db_name' MySQL database." >&3
fi

# * ========
# * The End
# * ======

# * Prompt to continue
echo -ne "\nPress any key to continue..." >&3
read whatever

clear >&3
