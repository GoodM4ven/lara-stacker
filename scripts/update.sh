#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> UPDATE ]|=-"

# * ===========
# * Validation
# * =========

# ? Source the helper function scripts first
functions=(
    "./scripts/functions/helpers/prompt.sh"
    "./scripts/functions/helpers/sourcer.sh"
)
for script in "${functions[@]}"; do
    if [[ ! -f "$script" ]] || ! chmod +x "$script" || ! source "$script"; then
        echo -e "Error: The essential script '$script' was not found. Exiting..."
        exit 1
    fi
done

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

# ? Set the echoing level
conditional_quiet="--quiet"
cancel_suppression=false
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
    conditional_quiet=""
    cancel_suppression=true
    ;;
esac

# * ========
# * Process
# * ======

# ? Update via Git
git pull origin main

# ? Ensure proper system ownership over files
sudo $lara_stacker_dir/scripts/helpers/permit.sh $lara_stacker_dir

# ? Ensure that the same script is executable again
chmod +x $lara_stacker_dir/lara-stacker.sh

# ? Add a flag to hide the updating option
touch /tmp/updated-lara-stacker.flag

# * ========
# * The End
# * ======

# * Display a successful message
echo -e "\nUpdated lara-stacker successfully.\n" >&3

# * Prompt to continue
echo -n "Press any key to continue..." >&3
read whatever

clear >&3
