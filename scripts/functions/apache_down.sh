apacheDown() {
    # ? Take in the arguments
    local site_name="$1"

    # ? Escape the site name for proper apache siting!
    local escaped_project_name=$(echo "$site_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    escaped_project_name=${escaped_project_name// /}

    # ? =============================================
    # ? Remove site's url from the system hosts file
    # ? ===========================================

    local pattern="127.0.0.1\s*$escaped_project_name\.test"

    if grep -q "$pattern" /etc/hosts; then
        sudo sed -i "/^$pattern/d" /etc/hosts

        echo -e "\nRemoved the site from [/etc/hosts] file." >&3
    else
        echo -e "\nThe site was not found in [/etc/hosts] file." >&3
    fi

    # ? Delete the site's cert files if they exist
    if [ -d "/var/www/html/$escaped_project_name/certs" ]; then
        sudo rm -rf /var/www/html/$escaped_project_name/certs

        echo -e "\nDeleted the site's SSL certificates." >&3
    fi

    # ? Purge the Apache config file and restart the service
    if [ -f "/etc/apache2/sites-available/$escaped_project_name.conf" ]; then
        sudo a2dissite $escaped_project_name.conf

        sudo rm /etc/apache2/sites-available/$escaped_project_name.conf

        sudo service apache2 restart

        echo -e "\nDeleted the site's Apache config file and restarted the service." >&3
    else
        echo -e "\nNo Apache config file was found to match '$escaped_project_name' site name." >&3
    fi
}
