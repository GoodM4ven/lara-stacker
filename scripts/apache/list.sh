#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> Apache Site Management |> LIST ]|=-\n"

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

# ? Confirm if setup script isn't run already
if [ ! -e "$PWD/done-setup.flag" ]; then
    echo -n "Setup script isn't run yet. Are you sure you want to continue? (y/n) "
    read confirmation

    case "$confirmation" in
    n|N|no|No|NO|nope|Nope|NOPE)
        echo -e "\nAborting...\n"

        echo -n "Press any key to continue..."
        read whatever

        clear
        exit 1
        ;;
    esac
fi

# * ========
# * Process
# * ======

# ? ========================================================================
# ? List the sites - omitting the default - and display their Apache status
# ? ======================================================================

SITE_COUNT=0

# Check sites from Apache configurations
for site in $(find /etc/apache2/sites-available/ -maxdepth 1 -name "*.conf" ! -name "000-default.conf" ! -name "default-ssl.conf" -type f); do
    # Extract just the site name without .conf
    site=$(basename $site .conf)
    if [ -f "/etc/apache2/sites-enabled/$site.conf" ]; then
        status="active"
    else
        status="inactive"
    fi
    echo "https://$(echo $site | sed 's/_/-/g').test - $status"
    SITE_COUNT=$((SITE_COUNT+1))
done

for dir in /var/www/html/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename $dir)
        # Replace underscores with hyphens for URL
        url_name=$(echo $dir_name | sed 's/_/-/g')
        if [ ! -f "/etc/apache2/sites-available/$dir_name.conf" ]; then
            echo "https://$url_name.test - inactive"
            SITE_COUNT=$((SITE_COUNT+1))
        fi
    fi
done

if [ $SITE_COUNT -gt 0 ]; then
    echo -e "\nSites count: $SITE_COUNT"
else
    echo -e "No Apache sites are found."
fi

# * ========
# * The End
# * ======

# * Prompt to continue
echo -ne "\nPress any key to continue..."
read whatever

clear
