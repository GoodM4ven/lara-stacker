#!/bin/bash

# Beginning Indicator
echo -e "\n=========================="
echo -e "=- TALL STACKER |> LIST -="
echo -e "==========================\n"

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
