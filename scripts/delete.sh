#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> Stacked Projects |> DELETE ]|=-\n"

# * ===========
# * Validation
# * =========

# Check if prompt script exists before sourcing
prompt_function_dir="./scripts/functions/prompt.sh"
if [[ ! -f $prompt_function_dir ]]; then
    echo -e "Error: Working directory isn't the script's main.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $prompt_function_dir

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

# * =================
# * Project Deletion
# * ===============

cd $PROJECTS_DIRECTORY

# Get the project name from the user
echo -n "Enter the project name: " >&3
read project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# Check if the project doesn't exist
if ! [ -d "$PROJECTS_DIRECTORY/$escaped_project_name" ]; then
    echo -e "\nProject $escaped_project_name doesn't exist. Cancelling...\n" >&3

    echo -n "Press any key to continue..." >&3
    read whatever

    clear >&3
    exit 1
fi

# Remove the site references from workspace settings
if [ $USING_VSC == true ]; then
    sudo rm /home/$USERNAME/Desktop/$escaped_project_name.code-workspace

    echo -e "\nRemoved the the VSC workspace." >&3
fi

# Remove site's url from /etc/hosts
sudo sed -i "/^127\.0\.0\.1\s*$escaped_project_name\.test/d" /etc/hosts

echo -e "\nRemoved the site from [/etc/hosts] file." >&3

# Disable and delete its Apache's config file
sudo a2dissite $project_name.conf

sudo rm /etc/apache2/sites-available/$project_name.conf

# Restart Apache service
sudo service apache2 restart

echo -e "\nDeleted the site's Apache config file and restarted the service." >&3

# Drop its MySQL database
project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

export MYSQL_PWD=$DB_PASSWORD
if mysql -u root -e "use $project_db_name"; then
    mysql -u root -e "DROP DATABASE $project_db_name;"

    echo -e "\nDropped '$project_db_name' database." >&3
fi

# Delete the MinIO storage
if [ -d "/home/$USERNAME/.config/minio/data/$escaped_project_name" ]; then
    rm -rf /home/$USERNAME/.config/minio/data/$escaped_project_name

    echo -e "\nDeleted '$escaped_project_name' MinIO storage." >&3
fi

# Delete project files
sudo rm -rf $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nDeleted project files." >&3

# * ========
# * The End
# * ======

# Display a success message
echo -e "\nProject $project_name deleted successfully!\n" >&3

echo -n "Press any key to continue..." >&3
read whatever

clear >&3
