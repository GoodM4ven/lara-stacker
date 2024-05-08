#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> TALL Projects Management |> DELETE ]|=-"

# * ===========
# * Validation
# * =========

# ? Source the helper function scripts first
functions=(
    "./scripts/functions/helpers/prompt.sh"
    "./scripts/functions/helpers/sourcer.sh"
)
for script in "${functions[@]}"; do
    if [[ ! -f "$script" ]] || ! chmod +x "$script" || ! source "$script"; then
        echo -e "Error: The essential script '$script' was not found. Exiting..."
        exit 1
    fi
done

# ? Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script."
fi

# ? Confirm if setup script isn't run already
sourcer "helpers.continueOrAbort"
if [ ! -e "$PWD/done-setup.flag" ]; then
    continueOrAbort "Setup script isn't run yet." "Aborting..."
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
    conditional_quiet=""
    cancel_suppression=true
    ;;
esac

# ? Check if VSCodium or VSC is installed
USING_VSC=false
if command -v codium >/dev/null 2>&1 || command -v code >/dev/null 2>&1; then
    USING_VSC=true
fi

# * ======
# * Input
# * ====

# ? Source the procedural function scripts now
sourcer "apacheDown" $cancel_suppression
sourcer "mysqlDown" $cancel_suppression

# ? Get the project name from the user
echo -ne "\nEnter the project name: " >&3
read project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

projects_directory=/var/www/html

# ? Check if the project doesn't exist
if ! [ -d "$projects_directory/$escaped_project_name" ]; then
    prompt "Project \"$escaped_project_name\" doesn't exist." "" $cancel_suppression
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
apacheDown $escaped_project_name $cancel_suppression

# ? Drop its MySQL database if it exists
mysqlDown $escaped_project_name

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
