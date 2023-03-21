#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script with sudo"
  exit
fi

# Prompt the user for confirmation before proceeding
read -p "Are you sure you want to synchronize all tall-* scripts? (y/n) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Action cancelled."
  exit 1
fi

dir="/home/goodm4ven/scripts"

echo -e ""

# Iterate over all files matching the pattern "tall-*.sh"
for file in "$dir"/tall-*.sh; do
  filename="$(basename "$file" .sh)"
  sudo cp "$file" "/usr/local/bin/$filename"

  echo "$file => /usr/local/bin/$filename"
done
