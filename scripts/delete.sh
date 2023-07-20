#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script as super-user (sudo)."
  exit
fi

# Confirm if setup script isn't run
if [ ! -e "$PWD/done-setup" ]; then
  echo ""
  read -p "Setup script isn't run yet. Are you sure you want to continue? (y/n) " confirmation

  case "$confirmation" in
    n|N|no|NO ) 
      echo -e "\nAborting...\n"
      exit 1
      ;;
  esac
fi

# Check if VSC is installed
found_vsc=false
if command -v code &>/dev/null; then
  found_vsc=true
elif command -v codium &>/dev/null; then
  found_vsc=true
fi

clear

# Beginning indicator
echo -e "-=|[ Lara-Stacker |> DELETE ]|=-\n"

# Get environment variables and defaults
source $PWD/.env

# Change directory to the projects' for suggestions
cd $PROJECTS_DIRECTORY

# Get the project name from the user
read -p "Enter the project name: " project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# Check if the project doesn't exist
if ! [ -d "$PROJECTS_DIRECTORY/$escaped_project_name" ]; then
  echo -e "\nProject $escaped_project_name doesn't exist. Cancelling...\n"
  exit 1
fi

# Remove the site references from workspace settings
if [[ $found_vsc == true && $VSC_WORKSPACE ]]; then
  sudo rm /home/$USERNAME/Desktop/$escaped_project_name.code-workspace >/dev/null 2>&1
  sudo rm /home/$USERNAME/Code/Workspaces/$escaped_project_name.code-workspace >/dev/null 2>&1

  echo -e "\nRemoved the the VSC workspace."
fi

# Remove site's url from /etc/hosts
sudo sed -i "/^127\.0\.0\.1\s*$escaped_project_name\.test/d" /etc/hosts

echo -e "\nRemoved the site from [/etc/hosts] file."

# Delete its Apache's config file then restart the service
sudo rm /etc/apache2/sites-available/$escaped_project_name.conf

sudo service apache2 restart

echo -e "\nDeleted the site's Apache config file and restarted the service."

# Drop its MySQL database
project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

if mysql -u root -p$DB_PASSWORD -e "use $project_db_name" 2> /dev/null; then
  mysql -u root -p$DB_PASSWORD -e "DROP DATABASE $project_db_name;" 2>/dev/null

  echo -e "\nDropped '$project_db_name' database."
fi

# Delete the MinIO storage
if [ -d "/home/$USERNAME/.config/minio/data/$escaped_project_name" ]; then
  rm -rf /home/$USERNAME/.config/minio/data/$escaped_project_name >/dev/null 2>&1

  echo -e "\nDeleted '$escaped_project_name' MinIO storage."
fi

# Delete project files
sudo rm -rf $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nDeleted project files."

# Display a success message
echo -e "\nProject $project_name deleted successfully!\n"

read -p "Press any key to continue..." whatever

clear
