#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script as super-user (sudo).\n"
  exit
fi

# Get environment variables
if [ ! -f "./.env" ]; then
  echo -e "\nPlease run the script from the directory where [.env] file is at.\n"
  exit
fi

lara_stacker_dir=$PWD

source ./.env

# Ensure all side scripts are executable
SCRIPTS=(
  "./scripts/setup.sh"
  "./scripts/list.sh"
  "./scripts/create.sh"
  "./scripts/delete.sh"
  "./scripts/update.sh"
  "./scripts/helpers/permit.sh"
)

for script in "${SCRIPTS[@]}"; do
  if [[ -f "$script" ]]; then
    if [[ ! -x "$script" ]]; then
      chmod +x "$script"
    fi
  else
    echo -e "\nError: $script does not exist"
  fi
done

clear

# Checking for updates
if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
  rm /tmp/updated-lara-stacker.flag
fi

echo -e "Checking for updates...\n"

update_available=false
current_version=$(grep -E "^## v[0-9]+" "./CHANGELOG.md" | head -1 | awk '{print $2}')
latest_version=$(curl --silent "https://api.github.com/repos/GoodM4ven/lara-stacker/releases/latest" | jq -r .tag_name)

clear

if [[ "$current_version" != "$latest_version" ]]; then
  echo -e "New version ($latest_version) available to download!\n"
  update_available=true
fi

# Loop until user chooses to exit
counter=0
while true; do
  counter=$((counter+1))

  echo -e "-=|[ Lara-Stacker [$current_version] ]|=-\n"

  echo -e "Supported Stacks:\n"
  echo -e "- TALL (TailwindCSS, AlpineJS, Livewire, Laravel)\n"
  
  echo -e "Available Operations:\n"

  # Controlling whether to show the updating option or not
  if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
    rm /tmp/updated-lara-stacker.flag
    update_available=false
  fi

  if [ "$update_available" == false ]; then
    options=("1. List Projects" "2. Create Project" "3. Delete Project" "4. Exit")
  else
    options=("1. List Projects" "2. Create Project" "3. Delete Project" "4. Exit" "5. Download Updates")
  fi

  if [[ ! -f "$lara_stacker_dir/done-setup.flag" ]]; then
    options+=("0. Initial Setup")
  fi

  options_count=$(( ${#options[@]} - 1 ))

  # Menu options
  for opt in "${options[@]}"; do
    echo "$opt "
  done

  echo ""
  if [[ $counter -eq 1 && "$1" ]]; then
    choice="$1"
  else
    read -p "Choose an operation (0-$options_count): " choice
  fi

  case $choice in
    0)
      if [[ -f "$lara_stacker_dir/done-setup.flag" ]]; then
        echo -e "\nInvalid option! Please type one the of digits in the list...\n"
      else
        sudo ./scripts/setup.sh
      fi
      ;;
    1)
      ./scripts/list.sh
      ;;
    2)
      sudo ./scripts/create.sh
      ;;
    3)
      sudo ./scripts/delete.sh
      ;;
    4)
      echo -e "\nExiting Lara-Stacker...\n"
      exit 0
      ;;
    5)
      if [ "$update_available" == false ]; then
        echo -e "\nInvalid option! Please type one the of digits in the list...\n"
      else
        sudo ./scripts/update.sh
      fi
      ;;
    *)
      echo -e "\nInvalid option! Please type one the of digits in the list...\n"
      ;;
  esac
done
