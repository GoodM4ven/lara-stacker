apacheUp() {
    # ? Take in the arguments
    local escaped_project_name="$1"
    local USERNAME="$2"
    local cancel_suppression="$3"
    local lara_stacker_dir="$4"
    local should_warn="${5:-false}"

    projects_directory=/var/www/html

    # ? Add an entry for the site to the /etc/hosts file
    echo -e "127.0.0.1 $escaped_project_name.test" | sudo tee -a /etc/hosts > /dev/null

    echo -e "\nAdded the site to [/etc/hosts] file." >&3

    # ? Generate SSL certificate files
    sudo -i -u $USERNAME bash <<EOF
cd $projects_directory/$escaped_project_name
if [ ! -d "./certs" ]; then
    mkdir certs
fi
cd certs
if $cancel_suppression; then
    mkcert $escaped_project_name.test 2>&1
else
    mkcert $escaped_project_name.test 2>&1 >/dev/null
fi
EOF

    echo -e "\nRegenerated SSL certificates for the site." >&3

    # ? Generate and enable an Apache2 config file for the project
    sudo touch /etc/apache2/sites-available/$escaped_project_name.conf

    sudo chmod 777 /etc/apache2/sites-available/$escaped_project_name.conf

    sudo echo "<VirtualHost *:80>
        ServerName $escaped_project_name.test
        DocumentRoot $projects_directory/$escaped_project_name/public
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
        FallbackResource /index.php
    </VirtualHost>

    <IfModule mod_ssl.c>
        <VirtualHost *:443>
            ServerName $escaped_project_name.test
            DocumentRoot $projects_directory/$escaped_project_name/public
            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined

            SSLEngine on
            SSLCertificateFile $projects_directory/$escaped_project_name/certs/$escaped_project_name.test.pem
            SSLCertificateKeyFile $projects_directory/$escaped_project_name/certs/$escaped_project_name.test-key.pem
            FallbackResource /index.php
        </VirtualHost>
    </IfModule>" | sudo tee /etc/apache2/sites-available/$escaped_project_name.conf > /dev/null

    sudo a2ensite -q $escaped_project_name

    sudo service apache2 restart

    echo -e "\nCreated and activated the site's Apache config file." >&3

    cd $projects_directory/$escaped_project_name

    # ? Link the site URL in the env file
    sed -i "s/APP_NAME=Laravel/APP_NAME=\"$escaped_project_name\"/g" ./.env
    sed -i "s|APP_URL=http://localhost|APP_URL=https://$escaped_project_name.test|g" ./.env

    echo -e "\nLinked the site URL in the project's env file." >&3

    # ? Confirm whether to apply our Vite file for SSL configuration or exit
    if $should_warn; then
        echo -ne "\nVite config file usually exists in old projects, yet we need to replace it for SSL configuration. Are you sure you want to continue? (y/n) " >&3
        read confirmation

        case "$confirmation" in
        n|N|no|No|NO|nope|Nope|NOPE)
            echo -e "\nApplying Vite config file was cancelled..." >&3

            return 1
            ;;
        esac
    fi

    # ? Override and modify the vite config for SSL configuration
    sudo cp $lara_stacker_dir/files/vite.config.js ./
    sed -i "s~<projectName>~$escaped_project_name~g" ./vite.config.js

    echo -e "\nApplied a new Vite config file to respect SSL." >&3
}
