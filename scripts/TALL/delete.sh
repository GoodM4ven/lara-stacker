#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> TALL Projects Management |> DELETE ]|=-\n"

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
sourceIfAvailable "apacheDown"
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
projects_directory=/var/www/html

# ? Set the echoing level
case $LOGGING_LEVEL in
# Notifications Only
1)
    exec 3>&1
    exec >/dev/null 2>&1
    ;;
# Notifications + Errors + Warnings
2)
    exec 3>&1
    exec >/dev/null
    ;;
# Everything
*)
    exec 3>&1
    ;;
esac

# ? Check for VSCodium or VSC existence
USING_VSC=false
if command -v codium >/dev/null 2>&1 || command -v code >/dev/null 2>&1; then
    USING_VSC=true
fi

# * ======
# * Input
# * ====

# ? Get the project name from the user
echo -n "Enter the project name: " >&3
read project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# ? Check if the project doesn't exist
if ! [ -d "$projects_directory/$escaped_project_name" ]; then
    prompt "Project \"$escaped_project_name\" doesn't exist."
fi

# * ========
# * Process
# * ======

cd $projects_directory

# ? Remove the project workspace if exists
if [[ $USING_VSC == true && $OPINIONATED == true ]]; then
    if [ -f /home/$USERNAME/Desktop/$escaped_project_name.code-workspace ]; then
        sudo rm /home/$USERNAME/Desktop/$escaped_project_name.code-workspace

        echo -e "\nRemoved the VSC workspace." >&3
    fi
fi

# ? Delete the Apache site
apacheDown $escaped_project_name

# ? Drop its MySQL database if it exists
mysqlDown $escaped_project_name $DB_PASSWORD

# ? Delete the MinIO storage
if [ -d "/home/$USERNAME/.config/minio/data/$escaped_project_name" ]; then
    rm -rf /home/$USERNAME/.config/minio/data/$escaped_project_name

    echo -e "\nDeleted '$escaped_project_name' MinIO storage." >&3
fi

# ? Delete project files
sudo rm -rf $projects_directory/$escaped_project_name

echo -e "\nDeleted project files." >&3

# * ========
# * The End
# * ======

# * Display a success message
echo -e "\nProject $project_name deleted successfully!\n" >&3

# * Prompt to continue
echo -n "Press any key to continue..." >&3
read whatever

clear >&3
