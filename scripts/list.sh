#!/bin/bash

clear

# Beginning indicator
echo -e "-=|[ Lara-Stacker |> LIST ]|=-\n"

# Get environment variables
source $PWD/.env

# Count the number of directories and list their names
count=0
for dir in $(ls -d $PROJECTS_DIRECTORY/*/ 2>/dev/null)
do
  if [ ! -d "$dir" ]
  then
    continue
  fi
  (( count++ ))
  echo "$dir"
done

if [ $count -gt 0 ]; then
  echo ""
fi

# Display the total count of directories found
echo -e "Total projects: $count\n"

read -p "Press any key to continue..." whatever

clear
