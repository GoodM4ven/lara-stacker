#!/bin/bash

clear

# * Display a status indicator
echo -e "-=|[ Lara-Stacker |> Apache Site Management |> LIST ]|=-\n"

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
    SITE_COUNT=$((SITE_COUNT + 1))
done

for dir in /var/www/html/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename $dir)
        # Replace underscores with hyphens for URL
        url_name=$(echo $dir_name | sed 's/_/-/g')
        if [ ! -f "/etc/apache2/sites-available/$dir_name.conf" ]; then
            echo "https://$url_name.test - inactive"
            SITE_COUNT=$((SITE_COUNT + 1))
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
