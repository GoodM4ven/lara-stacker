#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> TALL Projects Management |> CREATE ]|=-\n"

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

projects_directory=/var/www/html

# ? Get the project name from the user
echo -ne "Enter the project name: " >&3
read project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# ? Abort if the project directory already exists
if [ -d "$projects_directory/$escaped_project_name" ]; then
    prompt "Project folder already exists!" "Project creation cancelled."
fi

# * ===============
# * Initialization
# * =============

# ? Source the procedural function scripts now
sourcer "apacheUp"
sourcer "viteUp"
sourcer "mysqlUp"
sourcer "minioUp"
sourcer "workspaceUp"
sourcer "xdebugUp"

# ? =====================================================
# ? Create the Laravel project in the projects directory
# ? ===================================================

echo -e "\nInstalling the project via Composer..." >&3

cd $projects_directory/

composer create-project laravel/laravel $escaped_project_name -n $conditional_quiet

sudo $lara_stacker_dir/scripts/helpers/permit.sh $projects_directory/$escaped_project_name

# ? Create the Apache site
apacheUp $escaped_project_name $cancel_suppression

# ? Link the site to Vite's configuration
viteUp $escaped_project_name

# ? Generate a MySQL database if doesn't exit
mysqlUp $escaped_project_name

# ? Set up launch.json for debugging (Xdebug), if VSC is used
xdebugUp $USING_VSC $escaped_project_name

# ? Set up a MinIO storage
minioUp $escaped_project_name

# * ==============
# * Configuration
# * ============

cd $projects_directory/$escaped_project_name

# TODO Install vpremiss/tall-stacker package manager via Composer when it's ready -_-"

if [ -n "$EXPOSE_TOKEN" ]; then
    # ? Modify the TrustProxies middleware to work with Expose
    sed -i -E ':a;N;$!ba;s/(->withMiddleware\(function \(Middleware \$middleware\) \{\n\s*)\/\/(\n\s*\})/\1\$middleware->trustProxies(at: \x27*\x27); \2/g' ./bootstrap/app.php

    echo -e "\nTrusted all proxies for Expose compatibility." >&3
fi

if [ "$OPINIONATED" == true ]; then
    # ? Apply Prettier config
    sudo cp $lara_stacker_dir/files/.opinionated/.prettierrc ./.prettierrc

    echo -e "\nCopied an opinionated Prettier config file to the project." >&3

    if [ "$USING_VSC" == true ]; then
        # ? Create a dedicated VSC workspace in Desktop
        workspaceUp $escaped_project_name
    fi
fi

# * ========
# * The End
# * ======

# * Display a success message
echo -e "\nProject created successfully! You can access it at: [https://$escaped_project_name.test].\n" >&3

# * Prompt to continue
echo -n "Press any key to continue..." >&3
read whatever

clear >&3
