#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> LIST ]|=-\n"

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

# * ============
# * Preparation
# * ==========

# Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# * ============
# * The Listing
# * ==========

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

# * ========
# * The End
# * ======

# Display the total count of directories found
echo -e "Total projects: $count\n"

read -p "Press any key to continue..." whatever

clear
