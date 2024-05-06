#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> TALL Projects Management |> LIST ]|=-\n"

# * ===========
# * Validation
# * =========

# ? Check if prompt function exists and source it
function_path="./scripts/functions/prompt.sh"
if [[ ! -f $function_path ]]; then
    echo -e "Error: Working directory isn't the script's main; as \"prompt\" function is missing.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $function_path

# ? Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script."
fi

# * ============
# * Preparation
# * ==========

# ? Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env
projects_directory=/var/www/html

# * ========
# * Process
# * ======

# ? Count and list directories and their names
count=0
for dir in $(ls -d $projects_directory/*/ 2>/dev/null)
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

# * Display the total count of directories found
echo -e "Total projects: $count\n"

# * Prompt to continue
read -p "Press any key to continue..." whatever

clear
