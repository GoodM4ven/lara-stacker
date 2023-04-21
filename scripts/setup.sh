#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script as super-user (sudo)."
  exit
fi

# Check if VSC is installed
found_vsc=false
if command -v code &>/dev/null; then
  found_vsc=true
fi

# Beginning Indicator
echo -e "\n==========================="
echo -e "=- TALL STACKER |> SETUP -="
echo -e "===========================\n"

origin_dir=$PWD
# Get environment variables and defaults
source $origin_dir/.env

# Make the helper script executable
sudo chmod +x $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh

# git, php, apache2, redis and npm
sudo apt install git curl php apache2 php-curl php-xml php-dom php-bcmath redis-server npm -y >/dev/null 2>&1

sudo sed -i "s~post_max_size = 8M~post_max_size = 100M~g" /etc/php/8.1/apache2/php.ini
sudo sed -i "s~upload_max_filesize = 2M~upload_max_filesize = 100M~g" /etc/php/8.1/apache2/php.ini
sudo sed -i "s~variables_order = \"GPCS\"~variables_order = \"EGPCS\"~g" /etc/php/8.1/apache2/php.ini

sudo systemctl start apache2 >/dev/null 2>&1
sudo a2enmod rewrite >/dev/null 2>&1
sudo systemctl restart apache2 >/dev/null 2>&1
sudo a2enmod ssl >/dev/null 2>&1
sudo systemctl restart apache2 >/dev/null 2>&1

echo -e "\nInstalled Git, PHP, Apache, Redis and npm packages."

# media packages
sudo apt install php-imagick php-gd ghostscript ffmpeg -y >/dev/null 2>&1

echo -e "\nInstalled media packages. (imagick, GD, etc.)"

# Xdebug
sudo apt install php-xdebug -y >/dev/null 2>&1

mkdir -p /home/$USERNAME/.config/xdebug

sudo sed -i "s~zend_extension=xdebug.so~zend_extension=xdebug.so\n\nxdebug.log=\"/home/$USERNAME/.config/xdebug/xdebug.log\"\nxdebug.log_level=10\nxdebug.mode=develop,debug,coverage\nxdebug.client_port=9003\nxdebug.start_with_request=yes\nxdebug.discover_client_host=true~g" /etc/php/8.1/mods-available/xdebug.ini

sudo systemctl restart apache2 >/dev/null 2>&1

echo -e "\nInstalled PHP Xdebug."

# mkcert
sudo apt install mkcert libnss3-tools -y >/dev/null 2>&1

sudo -u $USERNAME mkcert -install >/dev/null 2>&1

echo -e "\nInstalled mkcert for SSL generation."

# Composer (globally)
sudo apt install composer -y >/dev/null 2>&1

echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
source ~/.bashrc

echo -e "\nInstalled composer globally."

# Grant user write permissions
sudo usermod -a -G www-data $USERNAME

echo -e "\nAdded the environment's user to [www-data] group."

# Opinionated VSC Keybindings
if [ "$OPINIONATED_KEYBINDINGS" == true ]; then
  # Copy settings first (which only initialize keybindings for now)
  sudo mkdir $PROJECTS_DIRECTORY/.vscode
  sudo cp $TALL_STACKER_DIRECTORY/files/.vscode/settings.json $PROJECTS_DIRECTORY/.vscode/
  sudo cp $TALL_STACKER_DIRECTORY/files/.opinionated/keybindings.json $PROJECTS_DIRECTORY/.vscode/

  sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/.vscode

  echo -e "\nCopied VSC workspace settings and extension key-bindings..."
fi

# CodeSniffer
composer global require "squizlabs/php_codesniffer=*" --dev --quiet

sudo mkdir $PROJECTS_DIRECTORY/.shared
sudo cp $TALL_STACKER_DIRECTORY/files/.shared/phpcs.xml $PROJECTS_DIRECTORY/.shared/

sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/.shared

echo -e "\nInstalled CodeSniffer globally."

# Link projects directory
mkdir /home/$USERNAME/Code/ >/dev/null 2>&1

cd /home/$USERNAME/Code
ln -s $PROJECTS_DIRECTORY/

final_folder=$(basename $PROJECTS_DIRECTORY)
mv $final_folder TALL

echo -e "\nLinked projects directory into [~/Code/TALL] directory."

# Create a VSC workspace (if installed)
if [[ $found_vsc == true ]]; then
  mkdir /home/$USERNAME/Code/Workspaces
  sudo mkdir $PROJECTS_DIRECTORY/.packages

  sudo cp $TALL_STACKER_DIRECTORY/files/.shared/tall.code-workspace /home/$USERNAME/Code/Workspaces/
  cd /home/$USERNAME/Desktop
  ln -s /home/$USERNAME/Code/Workspaces/tall.code-workspace

  sed -i "s/<username>/$USERNAME/g" /home/$USERNAME/Code/Workspaces/tall.code-workspace
  sed -i "s~<projectsDirectory>~$PROJECTS_DIRECTORY~g" /home/$USERNAME/Code/Workspaces/tall.code-workspace

  sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh /home/$USERNAME/Code/Workspaces/
  sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/.packages

  echo -e "\nCreated a VSC workspace on Desktop."
fi

# MySQL
sudo apt install mysql-server -y >/dev/null 2>&1

sudo systemctl start mysql

sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"

sudo apt install php-mysql -y >/dev/null 2>&1

sudo service apache2 restart

echo -e "\nInstalled MySQL and set the password to the environment's."

# Mailpit (service)
mkdir ~/Downloads/mailpit
cd ~/Downloads/mailpit
release_url=$(curl -s https://api.github.com/repos/axllent/mailpit/releases/latest | grep "browser_download_url.*mailpit-linux-amd64.tar.gz" | cut -d : -f 2,3 | tr -d \")
curl -L -o mailpit-linux-amd64.tar.gz $release_url >/dev/null 2>&1

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
sudo systemctl enable mailpit.service >/dev/null 2>&1
sudo systemctl start mailpit.service

echo -e "\nInstalled Mailpit and set up a service for it."

# MinIO (server, client and service)
mkdir minio
cd minio

wget https://dl.min.io/server/minio/release/linux-amd64/minio >/dev/null 2>&1
wget https://dl.min.io/client/mc/release/linux-amd64/mc >/dev/null 2>&1

sudo chown $USERNAME:$USERNAME minio
sudo chmod +x minio
sudo chown $USERNAME:$USERNAME mc
sudo chmod +x mc

sudo mv minio /usr/local/bin/
sudo mv mc /usr/local/bin/minio-client

cd ..
sudo rm -rf minio

mkdir -p /home/$USERNAME/.config/minio/data

echo "[Unit]
Description=MinIO
After=network.target

[Service]
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/minio server /home/$USERNAME/.config/minio/data
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/minio.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable minio.service >/dev/null 2>&1
sudo systemctl start minio.service

minio-client alias set myminio/ http://localhost:9000 minioadmin minioadmin >/dev/null 2>&1

echo -e "\nInstalled MinIO and set up a service for it."

# Expose
curl https://github.com/beyondcode/expose/raw/master/builds/expose -L --output expose >/dev/null 2>&1

sudo chown $USERNAME:$USERNAME expose
sudo chmod +x expose

sudo mv expose /usr/local/bin/

expose token $EXPOSE_TOKEN >/dev/null 2>&1

echo -e "\nInstalled MinIO and set up a service for it."

touch $origin_dir/done-setup
