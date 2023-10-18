#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> CREATE RAW ]|=-\n"

# * ===========
# * Validation
# * =========

# Check if prompt function exists and source it
function_path="./scripts/functions/prompt.sh"
if [[ ! -f $function_path ]]; then
    echo -e "Error: Working directory isn't the script's main.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $function_path

# Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script." true false
fi

# Confirm if setup script isn't run
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

# Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# Setting the echoing level
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

# * =================
# * Collecting Input
# * ===============

# Get the project path from the user
echo -ne "Enter the full project path (e.g., /home/$USERNAME/Code/my_project): " >&3
read full_directory

full_directory="${full_directory%/}"
project_path=$(dirname "$full_directory")
project_name=$(basename "$full_directory")

# Cancel if the project path directory doesn't exists
if [ ! -d "$project_path" ]; then
    prompt "\nThe project containing path doesn't exist!" "Raw project creation cancelled."
fi

# Cancel if the project directory already exists
if [ -d "$project_path/$project_name" ]; then
    prompt "\nProject folder already exist within the previously given path!" "Raw project creation cancelled."
fi

# * =================
# * Project Creation
# * ===============

# Create the Laravel raw project in the provided path and folder
echo -e "\nInstalling the project via Composer..." >&3

cd $project_path/
composer create-project --prefer-dist laravel/laravel $project_name -n $conditional_quiet

# Enforce permissions
sudo $lara_stacker_dir/scripts/helpers/permit.sh $project_path/$project_name

cd $project_path/$project_name

sed -i "s/APP_NAME=Laravel/APP_NAME=\"$project_name\"/g" ./.env

echo -e "\nCreated and named the raw Laravel application." >&3

# Set up launch.json for debugging (Xdebug)
mkdir $project_path/$project_name/.vscode
cd $project_path/$project_name/.vscode

sudo cp $lara_stacker_dir/files/.vscode/launch.json ./

sed -i "s~\[projectsDirectory\]~$project_path~g" ./launch.json
sed -i "s~\[projectName\]~$project_name~g" ./launch.json

echo -e "\nConfigured VSC debug settings for Xdebug support." >&3

# * ========
# * The End
# * ======

# Enforce permissions
sudo $lara_stacker_dir/scripts/helpers/permit.sh $project_path/$project_name

echo -e "\nUpdated directory and file permissions all around." >&3

# Display a success message
echo -e "\nRaw project created successfully! Run [art serve] from within its directory for launch.\n" >&3

echo -n "Press any key to continue..." >&3
read whatever

clear >&3
