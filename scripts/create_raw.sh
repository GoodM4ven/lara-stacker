#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> CREATE RAW ]|=-\n"

# * ===========
# * Validation
# * =========

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

# ? Get the project path from the user
echo -ne "Enter the full project path (e.g., /home/$USERNAME/Code/my_laravel_app): " >&3
read full_directory

full_directory="${full_directory%/}"
project_path=$(dirname "$full_directory")
project_name=$(basename "$full_directory")

# ? Cancel if the project path directory doesn't exists
if [ ! -d "$project_path" ]; then
    prompt "The project containing path doesn't exist!" "Raw project creation cancelled."
fi

# ? Cancel if the project directory already exists
if [ -d "$project_path/$project_name" ]; then
    prompt "Project folder already exist within the previously given path!" "Raw project creation cancelled."
fi

# * ========
# * Process
# * ======

# ? ===============================================================
# ? Create the Laravel raw project in the provided path and folder
# ? =============================================================

echo -e "\nInstalling the project via Composer..." >&3

cd $project_path/

composer create-project laravel/laravel $project_name -n $conditional_quiet

# ? Enforce permissions
sudo $lara_stacker_dir/scripts/helpers/permit.sh $project_path/$project_name

# ? =================================================
# ? Update the project name in environment variables
# ? ===============================================

cd $project_path/$project_name

sed -i "s/APP_NAME=Laravel/APP_NAME=\"$project_name\"/g" ./.env

echo -e "\nCreated and named the raw Laravel application." >&3

# ? Enforce permissions
sudo $lara_stacker_dir/scripts/helpers/permit.sh $project_path/$project_name

echo -e "\nUpdated directory and file permissions all around." >&3

# * ========
# * The End
# * ======

# * Display a success message
echo -e "\nLaravel project created successfully! Run [php artisan serve] from within its directory.\n" >&3

# * Prompt to continue
echo -n "Press any key to continue..." >&3
read whatever

clear >&3
