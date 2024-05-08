#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> TALL Projects Management |> IMPORT ]|=-\n"

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
sourceIfAvailable "apacheUp"
sourceIfAvailable "viteUp"
sourceIfAvailable "mysqlUp"
sourceIfAvailable "minioUp"
sourceIfAvailable "workspaceUp"
sourceIfAvailable "xdebugUp"

# ? Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script."
fi

# ? Confirm if setup script isn't run
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

# ? Setting the echoing level
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

# ? Check for VSCodium or VSC existence
USING_VSC=false
if command -v codium >/dev/null 2>&1 || command -v code >/dev/null 2>&1; then
    USING_VSC=true
fi

# * ======
# * Input
# * ====

# ? Get the project path from the user
echo -ne "Enter the full project path (e.g., /home/$USERNAME/Code/some_laravel_app): " >&3
read full_directory

full_directory="${full_directory%/}"
project_path=$(dirname "$full_directory")
project_name=$(basename "$full_directory")

# ? Cancel if the project path doesn't exists
if [ ! -d "$project_path/$project_name" ]; then
    prompt "The project path doesn't exist!" "Project importing cancelled."
fi

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# ? Cancel if the project already exists
if [ -d "$projects_directory/$escaped_project_name" ]; then
    prompt "A project with the same name already exists!" "Project importing cancelled."
fi

# * ===============
# * Initialization
# * =============

# ? ============================================
# ? Make a copy of the project in the directory
# ? ==========================================

sudo cp -r $project_path/$project_name $projects_directory/$escaped_project_name

sudo $lara_stacker_dir/scripts/helpers/permit.sh $projects_directory/$escaped_project_name

echo -e "\nThe project folder has been copied to "$projects_directory" directory." >&3

# ? Create the Apache site
apacheUp $escaped_project_name $USERNAME $cancel_suppression $lara_stacker_dir true

# ? Link the site to Vite's configuration
viteUp $projects_directory $escaped_project_name $lara_stacker_dir

# ? Generate a MySQL database if doesn't exit
mysqlUp $escaped_project_name $projects_directory $DB_PASSWORD

# ? Set up launch.json for debugging (Xdebug), if VSC is used
xdebugUp $USING_VSC $project_name $lara_stacker_dir $projects_directory

# ? Set up a MinIO storage
minioUp $escaped_project_name $USERNAME $lara_stacker_dir

# * ==============
# * Configuration
# * ============

cd $projects_directory/$escaped_project_name

# TODO Install TALL-STACKER package manager via Composer

if [ -n "$EXPOSE_TOKEN" ]; then
    # ? Modify the TrustProxies middleware to work with Expose
    sed -i "s/protected \$proxies;/protected \$proxies = '*';/g" ./app/Http/Middleware/TrustProxies.php

    echo -e "\nTrusted all proxies for Expose compatibility." >&3
fi

if [ "$OPINIONATED" == true ]; then
    if [ ! -f "./.prettierrc" ]; then
        # ? Apply Prettier config
        sudo cp $lara_stacker_dir/files/.opinionated/.prettierrc ./.prettierrc

        echo -e "\nCopied an opinionated Prettier config file to the project." >&3
    fi

    if [ "$USING_VSC" == true]; then
        # ? Create a dedicated VSC workspace in Desktop
        workspaceUp $escaped_project_name $USERNAME $lara_stacker_dir
    fi
fi

# * ========
# * The End
# * ======

# * Display a success message
echo -e "\nProject imported successfully! You can access it at: [https://$escaped_project_name.test].\n" >&3

# * Prompt to continue
echo -n "Press any key to continue..." >&3
read whatever

clear >&3
