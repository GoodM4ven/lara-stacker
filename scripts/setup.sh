#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> SETUP ]|=-\n"

# * ===========
# * Validation
# * =========

# Check if prompt function exists and source it
function_path="./scripts/functions/prompt.sh"
if [[ ! -f $function_path ]]; then
    echo -e "Error: Working directory isn't the script's main.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $function_path

# Ensure the script isn't ran directly
if [[ -z "$RAN_MAIN_SCRIPT" ]]; then
    prompt "Aborted for direct execution flow." "Please use the main [lara-stacker.sh] script." true false
fi

# Ensure that setup isn't done already
if [ -e "$PWD/done-setup.flag" ]; then
    echo -n "Setup script is already run! Are you sure you want to continue? (y/n) "
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

# * ============
# * Preparation
# * ==========

# Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# Setting the echoing level
conditional_quiet="--quiet"
cancel_suppression=false
case $LOGGING_LEVEL in
# Notifications Only
1)
    exec 3>&1
    exec > /dev/null 2>&1
    ;;
# Notifications + Errors + Warnings
2)
    exec 3>&1
    exec > /dev/null
    ;;
# Everything
*)
    exec 3>&1
    conditional_quiet=""
    cancel_suppression=true
    ;;
esac

# * ===========================
# * Installing System Packages
# * =========================

# Installing system packages...
echo -e "Installing system packages..." >&3

if $cancel_suppression; then
    sudo apt install git curl php apache2 php-curl php-xml php-dom php-bcmath php-zip redis-server npm -y 2>&1
else
    sudo apt install git curl php apache2 php-curl php-xml php-dom php-bcmath php-zip redis-server npm -y 2>&1 >/dev/null
fi

sudo sed -i "s~post_max_size = 8M~post_max_size = 100M~g" /etc/php/8.1/apache2/php.ini
sudo sed -i "s~upload_max_filesize = 2M~upload_max_filesize = 100M~g" /etc/php/8.1/apache2/php.ini
sudo sed -i "s~variables_order = \"GPCS\"~variables_order = \"EGPCS\"~g" /etc/php/8.1/apache2/php.ini
sudo sed -i'' -e 's/zend\.exception_ignore_args\s*=\s*On/zend.exception_ignore_args = Off/' /etc/php/8.1/apache2/php.ini
sudo sed -i'' -e 's/zend\.exception_ignore_args\s*=\s*On/zend.exception_ignore_args = Off/' /etc/php/8.1/cli/php.ini

sudo systemctl start apache2
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo a2enmod ssl
sudo systemctl restart apache2

# Grant user write permissions
sudo usermod -a -G www-data $USERNAME

echo -e "\nAdded the environment's user to [www-data] group." >&3

# Setup permissions permanently
sudo setfacl -Rdm g:www-data:rwx $PROJECTS_DIRECTORY
sudo chown -R :www-data $PROJECTS_DIRECTORY
sudo chmod -R g+rwx $PROJECTS_DIRECTORY

echo -e "\nSet up permissions in the projects directly permanently." >&3

# media packages
echo -e "\nInstalling media packages..." >&3

if $cancel_suppression; then
    sudo apt install php-imagick php-gd ghostscript ffmpeg -y 2>&1
else
    sudo apt install php-imagick php-gd ghostscript ffmpeg -y 2>&1 >/dev/null
fi

# Xdebug
echo -e "\nInstalling PHP Xdebug..." >&3

if $cancel_suppression; then
    sudo apt install php-xdebug -y 2>&1
else
    sudo apt install php-xdebug -y 2>&1 >/dev/null
fi

mkdir -p /home/$USERNAME/.config/xdebug
touch /home/$USERNAME/.config/xdebug/xdebug.log

sudo chown www-data:www-data /home/$USERNAME/.config/xdebug/xdebug.log
sudo chmod 664 /home/$USERNAME/.config/xdebug/xdebug.log

sudo sed -i "s~zend_extension=xdebug.so~zend_extension=xdebug.so\n\nxdebug.log=\"/home/$USERNAME/.config/xdebug/xdebug.log\"\nxdebug.log_level=10\nxdebug.mode=develop,debug,coverage\nxdebug.client_port=9003\nxdebug.start_with_request=yes\nxdebug.discover_client_host=true~g" /etc/php/8.1/mods-available/xdebug.ini

sudo $lara_stacker_dir/scripts/helpers/permit.sh /home/$USERNAME/.config/xdebug

sudo systemctl restart apache2

# Google Chrome (for Laravel Dusk)
cd /home/$USERNAME/Downloads/
if $cancel_suppression; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>&1
    sudo apt install -y ./google-chrome-stable_current_amd64.deb 2>&1
else
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>&1 >/dev/null
    sudo apt install -y ./google-chrome-stable_current_amd64.deb 2>&1 >/dev/null
fi
rm google-chrome-stable_current_amd64.deb

# Bun
echo -e "\nInstalling Bun front-end package manager..." >&3

sudo -i -u $USERNAME bash <<EOF
if $cancel_suppression; then
    curl -fsSL https://bun.sh/install | bash 2>&1
else
    curl -fsSL https://bun.sh/install | bash 2>&1 >/dev/null
fi
EOF

export BUN="/home/$USERNAME/.bun/bin/bun"

# Graphite
sudo -i -u $USERNAME bash <<EOF
if $cancel_suppression; then
    $BUN add -g @withgraphite/graphite-cli@stable 2>&1
else
    $BUN add -g @withgraphite/graphite-cli@stable 2>&1 >/dev/null
fi
EOF

echo -e "\nInstalled Graphite version control CLI..." >&3

# Composer (globally)
echo -e "\nInstalling composer globally..." >&3

if $cancel_suppression; then
    sudo apt install composer -y 2>&1
else
    sudo apt install composer -y 2>&1 >/dev/null
fi

echo -e "\nexport PATH=\"\$PATH:/home/$USERNAME/.config/composer/vendor/bin\"" >> /home/$USERNAME/.bashrc

# mkcert
echo -e "\nInstalling mkcert for SSL generation..." >&3

if $cancel_suppression; then
    sudo apt install mkcert libnss3-tools -y 2>&1
else
    sudo apt install mkcert libnss3-tools -y 2>&1 >/dev/null
fi

# MySQL
echo -e "\nInstalling MySQL and setting the password to the env-file's..." >&3

if $cancel_suppression; then
    sudo apt install mysql-server -y 2>&1
else
    sudo apt install mysql-server -y 2>&1 >/dev/null
fi

sudo systemctl start mysql

sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"

if $cancel_suppression; then
    sudo apt install php-mysql -y 2>&1
else
    sudo apt install php-mysql -y 2>&1 >/dev/null
fi

sudo service apache2 restart

# Pest Database
export MYSQL_PWD=password
mysql -u root -e "CREATE DATABASE pest;"

echo -e "\nCreated a \"Pest\" MySQL database for testing." >&3

# Mailpit (service)
echo -e "\nInstalling Mailpit and setting up a service for it..." >&3

mkdir /home/$USERNAME/Downloads/mailpit
cd /home/$USERNAME/Downloads/mailpit

release_url=$(curl -s https://api.github.com/repos/axllent/mailpit/releases/latest | grep "browser_download_url.*mailpit-linux-amd64.tar.gz" | cut -d : -f 2,3 | tr -d \")
if $cancel_suppression; then
    curl -L -o mailpit-linux-amd64.tar.gz $release_url 2>&1
else
    curl -L -o mailpit-linux-amd64.tar.gz $release_url 2>&1 >/dev/null
fi

tar -xzf mailpit-linux-amd64.tar.gz
sudo chown $USERNAME:$USERNAME mailpit
sudo chmod +x mailpit
sudo mv mailpit /usr/local/bin/

cd ..
sudo rm -rf mailpit

echo "[Unit]
Description=Mailpit
After=network.target

[Service]
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/mailpit
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mailpit.service > /dev/null

sudo systemctl daemon-reload
if $cancel_suppression; then
    sudo systemctl enable mailpit.service 2>&1
else
    sudo systemctl enable mailpit.service 2>&1 >/dev/null
fi
sudo systemctl start mailpit.service

# MinIO (server, client, and service)
echo -e "\nInstalling MinIO and setting up a service for it..." >&3

mkdir /home/$USERNAME/Downloads/minio
cd /home/$USERNAME/Downloads/minio

if $cancel_suppression; then
    wget https://dl.min.io/server/minio/release/linux-amd64/minio 2>&1
    wget https://dl.min.io/client/mc/release/linux-amd64/mc 2>&1
else
    wget https://dl.min.io/server/minio/release/linux-amd64/minio 2>&1 >/dev/null
    wget https://dl.min.io/client/mc/release/linux-amd64/mc 2>&1 >/dev/null
fi

sudo chown $USERNAME:$USERNAME minio
sudo chmod +x minio
sudo chown $USERNAME:$USERNAME mc
sudo chmod +x mc

sudo mv minio /usr/local/bin/
sudo mv mc /usr/local/bin/minio-client

cd ..
sudo rm -rf minio

mkdir -p /home/$USERNAME/.config/minio/data
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/minio/data

echo "[Unit]
Description=MinIO
After=network.target

[Service]
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/usr/local/bin
Environment=\"MINIO_ROOT_USER=minioadmin\"
Environment=\"MINIO_ROOT_PASSWORD=minioadmin\"
ExecStart=/usr/local/bin/minio server /home/$USERNAME/.config/minio/data --console-address \":9001\"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/minio.service > /dev/null

sudo systemctl daemon-reload
if $cancel_suppression; then
    sudo systemctl enable minio.service 2>&1
else
    sudo systemctl enable minio.service 2>&1 >/dev/null
fi
sudo systemctl start minio.service

sleep 5

sudo -i -u $USERNAME bash <<EOF
minio-client alias set myminio/ http://localhost:9000 minioadmin minioadmin
EOF

if [ -n "$EXPOSE_TOKEN" ]; then
    # Expose
    echo -e "\nInstalling Expose and setting up its token to be ready to use..." >&3

    cd /home/$USERNAME/Downloads
    if $cancel_suppression; then
        curl https://github.com/beyondcode/expose/raw/master/builds/expose -L --output expose 2>&1
    else
        curl https://github.com/beyondcode/expose/raw/master/builds/expose -L --output expose 2>&1 >/dev/null
    fi

    sudo chown $USERNAME:$USERNAME expose
    sudo chmod +x expose

    sudo mv expose /usr/local/bin/

    sudo -i -u $USERNAME bash <<EOF
    expose token $EXPOSE_TOKEN
EOF
fi

# * =========================
# * Extra Opinionated Setups
# * =======================

if [ "$OPINIONATED" == true ]; then
    # Link projects directory
    sudo -i -u $USERNAME bash <<EOF
mkdir /home/$USERNAME/Code
cd /home/$USERNAME/Code
ln -s $PROJECTS_DIRECTORY/
EOF

    cd /home/$USERNAME/Code
    final_folder=$(basename $PROJECTS_DIRECTORY)
    sudo mv $final_folder ./Laravel

    sudo $lara_stacker_dir/scripts/helpers/permit.sh /home/$USERNAME/Code

    echo -e "\nLinked projects directory into [~/Code/Laravel] directory." >&3

    # Install Firacode font (if VSC installed)
    if [[ $USING_VSC == true ]]; then
        if $cancel_suppression; then
            sudo apt install fonts-firacode -y 2>&1
        else
            sudo apt install fonts-firacode -y 2>&1 >/dev/null
        fi

        echo -e "\nInstalled Firacode font for VSC." >&3
    fi

    # Create .packages directory
    sudo mkdir $PROJECTS_DIRECTORY/.packages

    sudo $lara_stacker_dir/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/.packages

    echo -e "\nCreated a [$PROJECTS_DIRECTORY/.packages] directory." >&3

    # Add helper aliases to .bashrc
    echo -e "\n# Laravel Aliases\nalias cda='composer dump-autoload'\nalias art='php artisan'\nalias fresh='php artisan migrate:fresh'\nalias mfs='php artisan migrate:fresh --seed'\nalias opt='php artisan optimize:clear'\nalias dev='bun run dev'\n" >> /home/$USERNAME/.bashrc

    echo -e "\nAdded some helper aliases to [.bashrc] file. Check 'art' out!" >&3
fi

# * ========
# * The End
# * ======

touch $lara_stacker_dir/done-setup.flag
sudo $lara_stacker_dir/scripts/helpers/permit.sh $lara_stacker_dir/done-setup.flag

echo -e "\nSetup done successfully. The following are required:\n" >&3

echo -e "- Ensure that the browser is ran properly once." >&3
echo -e "- Run [mkcert -install] command so you could generate SSL certificates." >&3
echo -e "- Restart the operating system for permissions and services to work.\n" >&3

echo -n "Press any key to continue..." >&3
read whatever

clear >&3
