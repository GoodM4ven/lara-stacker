#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> Apache Site Management |> ENABLE ]|=-"

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

# ? Confirm if setup script isn't run already
sourcer "helpers.continueOrAbort"
if [ ! -e "$PWD/done-setup.flag" ]; then
    continueOrAbort "Setup script isn't run yet." "Aborting..."
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

# ? Source the procedural function scripts now
sourcer "apacheUp" $cancel_suppression
sourcer "viteUp" $cancel_suppression

# ? Get the site name
echo -ne "\nEnter the site name: " >&3
read site_name

# ? Host the Apache site if it doesn't exist
apacheUp $site_name $cancel_suppression

escaped_project_name=$(echo "$site_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# ? Link the site to Vite's configuration
viteUp $site_name $escaped_project_name

# * ========
# * The End
# * ======

# * Prompt to continue
echo -ne "\nPress any key to continue..." >&3
read whatever

clear >&3
