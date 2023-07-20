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

source ./.env

# Ensure all side scripts are executable
SCRIPTS=(
  "./scripts/setup.sh"
  "./scripts/list.sh"
  "./scripts/create.sh"
  "./scripts/delete.sh"
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

# Menu options
options=("1. List Projects" "2. Create Project" "3. Delete Project" "4. Exit" "0. Initial Setup")
options_count=$(( ${#options[@]} - 1 ))

echo ""

# Loop until user chooses to exit
counter=0
while true; do
  counter=$((counter+1))
  echo -e "-=|[ Lara-Stacker ]|=-\n"
  echo -e "Supported Stacks:\n"
  echo -e "- TALL (TailwindCSS, AlpineJS, Livewire, Laravel)\n"
  echo -e "Available Operations:\n"
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
      sudo ./scripts/setup.sh
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
    *)
      echo -e "\nInvalid option! Please type one the of digits in the list...\n"
      ;;
  esac
done
