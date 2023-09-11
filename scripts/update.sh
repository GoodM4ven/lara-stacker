#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> UPDATE ]|=-\n"

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

# * ============
# * Preparation
# * ==========

# Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# Setting the echoing level
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
        ;;
esac

# * =========
# * Updating
# * =======

cd "$lara_stacker_dir"

# Check if the .git directory exists (or clone it anew)
if [ -d ".git" ]; then
    echo "Fetching the latest updates from GitHub..." >&3

    git pull origin master || {
        echo -e "Error updating from GitHub. Please check your internet connection or repository URL." >&3
        exit 1
    }
else
    echo -e "Fresh installation from GitHub..." >&3

    mv $lara_stacker_dir $lara_stacker_dir-backup-$(date +"%Y%m%d%H%M%S")

    repo_url="https://github.com/GoodM4ven/lara-stacker.git"

    git clone $repo_url $lara_stacker_dir || {
        echo -e "\nError cloning from GitHub. Please check your internet connection or repository URL." >&3
        exit 1
    }

    sudo $lara_stacker_dir/scripts/helpers/permit.sh $lara_stacker_dir

    cd $lara_stacker_dir
fi

# Make the script executable again
chmod +x ./lara-stacker.sh

# Add a flag to hide the updating option
touch /tmp/updated-lara-stacker.flag

# * ========
# * The End
# * ======

echo -e "\nUpdated lara-stacker successfully.\n" >&3

echo -n "Press any key to continue..." >&3
read whatever

clear >&3
