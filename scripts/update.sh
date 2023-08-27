#!/bin/bash

clear

# Beginning indicator
echo -e "-=|[ Lara-Stacker |> UPDATE ]|=-\n"

lara_stacker_dir=$PWD

cd "$lara_stacker_dir"

# Get environment variables and defaults
source ./.env

# Check if the .git directory exists (or clone it anew)
if [ -d ".git" ]; then
  echo "Fetching the latest updates from GitHub..."

  git pull origin master > /dev/null 2>&1 || {
    echo -e "Error updating from GitHub. Please check your internet connection or repository URL."
    exit 1
  }
else
  echo -e "Fresh installation from GitHub..."

  mv $lara_stacker_dir $lara_stacker_dir-backup-$(date +"%Y%m%d%H%M%S")

  repo_url="https://github.com/GoodM4ven/lara-stacker.git"

  git clone $repo_url $lara_stacker_dir > /dev/null 2>&1 || {
    echo -e "\nError cloning from GitHub. Please check your internet connection or repository URL."
    exit 1
  }

  sudo $lara_stacker_dir/scripts/helpers/permit.sh $lara_stacker_dir

  cd $lara_stacker_dir
fi

# Make the script executable again
chmod +x ./lara-stacker.sh

# Done
touch /tmp/updated-lara-stacker.flag

echo -e "\nUpdated lara-stacker successfully.\n"

read -p "Press any key to continue..." whatever

clear
