#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script as super-user (sudo).\n"
  exit
fi

# Confirm if setup script isn't run
if [ ! -e "$PWD/done-setup" ]; then
  echo ""
  read -p "Setup script isn't run yet. Are you sure you want to continue? (y/n) " confirmation

  case "$confirmation" in
    n|N|no|NO ) 
      echo -e "\nAborting...\n"
      exit 1
      ;;
  esac
fi

# Check if VSC is installed
found_vsc=false
if command -v code &>/dev/null; then
  found_vsc=true
elif command -v codium &>/dev/null; then
  found_vsc=true
fi

clear

# Beginning indicator
echo -e "-=|[ Lara-Stacker |> CREATE ]|=-\n"

# Get environment variables and defaults
source $PWD/.env

# * =================
# * Collecting Input
# * ===============

# Get the project name from the user
read -p "Enter the project name: " project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# Check if the project directory already exists
if [ -d "$PROJECTS_DIRECTORY/$escaped_project_name" ]; then
  echo -e "\nProject folder already exists. Cancelling...\n"
  exit 1
fi

# Get the stack choice
while true; do
  read -p "Enter the Laravel stack (tall, tvil, tvil-ssr, tril, tril-ssr, api): " laravel_stack

  case "$laravel_stack" in
    tall )
      break;;
    tvil|tvil-ssr|tril|tril-ssr|api )
      echo "Stack script not ready yet..."
      ;;
    * )
      echo "Unknown stack.";;
  esac
done

# Get the multilingual choice
read -p "Is the project multi-lingual? (y/n) " is_multilingual
if [ "$is_multilingual" = "n" ] || [ "$is_multilingual" = "N" ] || [ "$is_multilingual" = "no" ] || [ "$is_multilingual" = "NO" ]; then
  is_multilingual=false
else
  is_multilingual=true
fi

# Get the pest choice
read -p "Do you want to use Laravel Pest over PHPUnit for testing? (y/n) " use_pest
if [ "$use_pest" = "n" ] || [ "$use_pest" = "N" ] || [ "$use_pest" = "no" ] || [ "$use_pest" = "NO" ]; then
  use_pest=false
else
  use_pest=true
fi

# * =================
# * Project Creation
# * ===============

# Create the Laravel project in the projects directory
echo ""
echo -e "Installing the project via Composer..."

cd $PROJECTS_DIRECTORY/
composer create-project --prefer-dist laravel/laravel $escaped_project_name -n --quiet

sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

# Generate an SSL certificate via mkcert
sudo -i -u $USERNAME bash <<EOF >/dev/null 2>&1
cd /home/$USERNAME/
mkcert $escaped_project_name.test
mkdir $PROJECTS_DIRECTORY/$escaped_project_name/certs
mv ./$escaped_project_name.test.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
mv ./$escaped_project_name.test-key.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
EOF

echo -e "\nGenerated SSL certificate via mkcert."

# Add an entry for the site to the /etc/hosts file
echo -e "127.0.0.1 $escaped_project_name.test" | sudo tee -a /etc/hosts > /dev/null

echo -e "\nAdded the site to [/etc/hosts] file."

# Generate and enable an Apache2 config file for the project
sudo touch /etc/apache2/sites-available/$escaped_project_name.conf

sudo chmod 777 /etc/apache2/sites-available/$escaped_project_name.conf

sudo echo "<VirtualHost *:80>
    ServerName $escaped_project_name.test
    DocumentRoot $PROJECTS_DIRECTORY/$escaped_project_name/public
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
        DocumentRoot $PROJECTS_DIRECTORY/$escaped_project_name/public
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLCertificateFile $PROJECTS_DIRECTORY/$escaped_project_name/certs/$escaped_project_name.test.pem
        SSLCertificateKeyFile $PROJECTS_DIRECTORY/$escaped_project_name/certs/$escaped_project_name.test-key.pem
        FallbackResource /index.php
    </VirtualHost>
</IfModule>" | sudo tee /etc/apache2/sites-available/$escaped_project_name.conf > /dev/null

sudo a2ensite -q $escaped_project_name >/dev/null 2>&1

sudo service apache2 restart

cd $PROJECTS_DIRECTORY/$escaped_project_name
sed -i "s/APP_NAME=Laravel/APP_NAME=\"$project_name\"/g" ./.env
sed -i "s|APP_URL=http://localhost|APP_URL=https://$escaped_project_name.test\nAPP_LOCALES=ar,en|g" ./.env

echo -e "\nCreated and activated the site's Apache config file."

# Generate a MySQL database if doesn't exit
project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

cd $PROJECTS_DIRECTORY/$escaped_project_name
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$project_db_name/g" ./.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" ./.env

if mysql -u root -p$DB_PASSWORD -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$project_db_name'" 2> /dev/null | grep "$project_db_name" > /dev/null; then
  echo -e "\nMySQL database '$project_db_name' already exists!"
else
  mysql -u root -p$DB_PASSWORD -e "CREATE DATABASE $project_db_name;" 2> /dev/null
  echo -e "\nCreated '$project_db_name' MySQL database."
fi

# Set up launch.json for debugging (Xdebug)
mkdir $PROJECTS_DIRECTORY/$escaped_project_name/.vscode
cd $PROJECTS_DIRECTORY/$escaped_project_name/.vscode

sudo cp $LARA_STACKER_DIRECTORY/files/.vscode/launch.json ./

sed -i "s~\[projectsDirectory\]~$PROJECTS_DIRECTORY~g" ./launch.json
sed -i "s~\[projectName\]~$escaped_project_name~g" ./launch.json

echo -e "\nConfigured VSC debug settings for Xdebug support."

# Set up a MinIO storage
cd /home/$USERNAME/.config/minio/data/
minio-client mb --region=us-east-1 $escaped_project_name >/dev/null 2>&1

sudo -i -u $USERNAME bash <<EOF >/dev/null 2>&1
cd /home/$USERNAME/
minio-client anonymous set public myminio/$escaped_project_name
EOF

sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh /home/$USERNAME/.config/minio/data/$escaped_project_name

cd $PROJECTS_DIRECTORY/$escaped_project_name
sed -i "s/FILESYSTEM_DISK=local/FILESYSTEM_DISK=s3/g" ./.env
sed -i "s/AWS_ACCESS_KEY_ID=/AWS_ACCESS_KEY_ID=minioadmin/g" ./.env
sed -i "s/AWS_SECRET_ACCESS_KEY=/AWS_SECRET_ACCESS_KEY=minioadmin/g" ./.env
sed -i "s/AWS_BUCKET=/AWS_BUCKET=$escaped_project_name/g" ./.env
sed -i "s|AWS_USE_PATH_STYLE_ENDPOINT=false|AWS_ENDPOINT=http://localhost:9000\nAWS_URL=http://localhost:9000/$escaped_project_name\nAWS_USE_PATH_STYLE_ENDPOINT=true|g" ./.env

echo -e "\nSet up a MinIO storage for the project."

# * ==================
# * Composer Packages
# * ================

echo -e "\nInstalling Composer packages..."

cd $PROJECTS_DIRECTORY/$escaped_project_name

# Breeze
composer require --dev laravel/breeze laravel/telescope --with-all-dependencies -n --quiet >/dev/null 2>&1

if [ "$laravel_stack" = "tall" ]; then
  stack="blade"
fi
if [ "$laravel_stack" = "tvil" ] || [ "$laravel_stack" = "tvil-ssr" ]; then
  stack="vue"
fi
if [ "$laravel_stack" = "tril" ] || [ "$laravel_stack" = "tril-ssr" ]; then
  stack="react"
fi
ssr=""
if [ "$laravel_stack" = "tvil-ssr" ] || [ "$laravel_stack" = "tril-ssr" ]; then
  ssr="--ssr"
fi
pest=""
if [ "$use_pest" == true ]; then
  pest="--pest"
fi
php artisan breeze:install $stack --dark --quiet $ssr $pest >/dev/null 2>&1

# Pest
if [ "$use_pest" == true ]; then
  livewire_plugin=""
  if [ "$laravel_stack" = "tall" ]; then
    livewire_plugin="pestphp/pest-plugin-livewire"
  fi
  composer require --dev -n --quiet pestphp/pest-plugin-watch pestphp/pest-plugin-faker $livewire_plugin
fi

# laravel-lang (dev)
if [ "$is_multilingual" == true ]; then
  composer require --dev -n --quiet laravel-lang/lang
fi

# Dev Packages
composer require laracasts/cypress --dev -n --quiet

# Non-dev Packages...
composer require --with-all-dependencies -n --quiet league/flysystem-aws-s3-v3 "^3.0" predis/predis laravel/scout "spatie/laravel-medialibrary:^10.0.0" spatie/eloquent-sortable spatie/laravel-sluggable spatie/laravel-tags spatie/laravel-settings:"^2.2" spatie/laravel-options blade-ui-kit/blade-icons spatie/laravel-permission qruto/laravel-wave gehrisandro/tailwind-merge-laravel

# Language Packages...
if [ "$is_multilingual" == true ]; then
  composer require -n --quiet --with-all-dependencies mcamara/laravel-localization spatie/laravel-translatable filament/spatie-laravel-translatable-plugin:"^2.0"
fi

# TALL Packages...
if [ "$laravel_stack" = "tall" ]; then
  composer require -n --quiet --with-all-dependencies livewire/livewire filament/filament:"^2.0" filament/forms:"^2.0" filament/tables:"^2.0" filament/notifications:"^2.0" filament/spatie-laravel-media-library-plugin:"^2.0" filament/spatie-laravel-tags-plugin:"^2.0" filament/spatie-laravel-settings-plugin:"^2.0" danharrin/livewire-rate-limiting bezhansalleh/filament-shield goodm4ven/blurred-image
fi

# * =============
# * NPM Packages
# * ===========

echo -e "\nInstalling NPM packages..."

cd $PROJECTS_DIRECTORY/$escaped_project_name

# TALL packages...
if [ "$laravel_stack" = "tall" ]; then
  npm install @alpinejs/mask @alpinejs/intersect @alpinejs/persist @alpinejs/focus @alpinejs/collapse @alpinejs/morph >/dev/null 2>&1

  # Uninstall axios
  npm uninstall axios >/dev/null 2>&1

  # TALL Dev Packages...
  npm install -D @defstudio/vite-livewire-plugin @awcodes/alpine-floating-ui alpinejs-breakpoints >/dev/null 2>&1
fi

# Laravel-Wave
npm install laravel-wave >/dev/null 2>&1

# Dev Packages...
npm install -D tailwindcss postcss autoprefixer @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio @tailwindcss/container-queries tippy.js cypress >/dev/null 2>&1

# * =======================
# * Package Configurations
# * =====================

cd $PROJECTS_DIRECTORY/$escaped_project_name

# TaliwindCSS
if [ "$laravel_stack" = "tall" ]; then
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/css/app.css ./resources/css/
fi
sudo cp $LARA_STACKER_DIRECTORY/files/postcss.config.js ./
sudo cp $LARA_STACKER_DIRECTORY/files/tailwind.config.js ./

php artisan vendor:publish --provider="TailwindMerge\Laravel\ServiceProvider" --quiet

echo -e "\nConfigured TailwindCSS framework and TailwindMerge package."

# Cypress setup
php artisan cypress:boilerplate --quiet

echo -e "\nConfigured front-end testing with Cypress."

# Blade Icons
mkdir -p ./resources/svgs/custom
sudo cp $LARA_STACKER_DIRECTORY/files/config/blade-icons.php ./config/
sudo cp -r $LARA_STACKER_DIRECTORY/files/resources/svgs/general ./resources/svgs/
sudo cp $LARA_STACKER_DIRECTORY/files/resources/svgs/custom/laravel.svg ./resources/svgs/custom/

echo -e "\nConfigured Blade Icons with Heroicons as the 'general' set."

# Install Redis, predis and the facade alias
if [ "$laravel_stack" = "tall" ]; then
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/app/Providers/FilamentServiceProvider.php ./app/Providers/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/config/app.php ./config/
else
  sudo cp $LARA_STACKER_DIRECTORY/files/config/app.php ./config/
fi

sed -i "s/REDIS_HOST=127.0.0.1/REDIS_CLIENT=predis\nREDIS_HOST=127.0.0.1/g" ./.env

echo -e "\nConfigured Redis, predis and exposed Redis facade globally."

# Modify the TrustProxies middleware to work with Expose
sed -i "s/protected \$proxies;/protected \$proxies = '*';/g" ./app/Http/Middleware/TrustProxies.php

echo -e "\nTrusted all proxies for Expose compatibility."

if [ "$is_multilingual" == true ]; then
  # Publish lang folder
  php artisan lang:publish --quiet

  echo -e "\nPublished the [lang] folder."

  # Laravel Localization
  php artisan vendor:publish --provider="Mcamara\LaravelLocalization\LaravelLocalizationServiceProvider" --quiet

  sudo cp $LARA_STACKER_DIRECTORY/files/app/Http/Kernel.php ./app/Http/
  sudo cp $LARA_STACKER_DIRECTORY/files/config/laravellocalization.php ./config/
  php artisan lang:add ar --quiet

  echo -e "\nConfigured Laravel Localization and enabled AR & EN locales."

  # Laravel Translatable
  php artisan vendor:publish --tag=filament-spatie-laravel-translatable-plugin-config --quiet

  echo -e "\nConfigured Laravel Translatable."
fi

# Laravel Telescope
php artisan telescope:install --quiet

php artisan migrate --quiet

sudo cp $LARA_STACKER_DIRECTORY/files/app/Providers/AppServiceProvider.php ./app/Providers/
sed -i "s~\"dont-discover\": \[\]~\"dont-discover\": \[\n                \"laravel/telescope\"\n            \]~g" ./composer.json
echo -e "\nTELESCOPE_ENABLED=true" | tee -a ./.env >/dev/null 2>&1

echo -e "\nConfigured Laravel Telescope."

# Laravel Scout
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider" --quiet

echo -e "\nSCOUT_DRIVER=database" | tee -a ./.env >/dev/null 2>&1

echo -e "\nConfigured Laravel Scout."

# Laravel Media Library
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="migrations" --quiet
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="config" --quiet

php artisan migrate --quiet

sed -i "s~'CacheControl' => 'max-age=604800',~'CacheControl' => 'max-age=604800',\n            'visibility' => 'public',~g" ./config/media-library.php

echo -e "\nMEDIA_DISK=s3" | tee -a ./.env >/dev/null 2>&1

echo -e "\nConfigured Laravel Media Library to work with MinIO."

# Eloquent Sortable
php artisan vendor:publish --tag=eloquent-sortable-config --quiet

sed -i "s/'order_column',/'sorting_order',/g" ./config/eloquent-sortable.php

echo -e "\nInstalled Eloquent Sortable and set 'sorting_order' as the default column."

# Laravel Sluggable
echo -e "\nConfigured Laravel Sluggable."

# Laravel Tags
php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-migrations" --quiet
php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-config" --quiet

php artisan migrate --quiet

echo -e "\nConfigured Laravel Tags."

# Laravel Options
php artisan vendor:publish --tag="options-config" --quiet

echo -e "\nConfigured Laravel Options."

# Laravel Permission
cp $LARA_STACKER_DIRECTORY/files/app/Models/User.php ./app/Models/
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --quiet

echo -e "\nConfigured Laravel Permission."

# Laravel Settings
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="migrations" --quiet
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="settings" --quiet
php artisan migrate --quiet

echo -e "\nConfigured Laravel Settings."

# Laravel-Wave
php artisan vendor:publish --tag="wave-config" --quiet

sed -i "s/BROADCAST_DRIVER=log/BROADCAST_DRIVER=redis/g" ./.env

mkdir ./resources/js/core
sudo cp $LARA_STACKER_DIRECTORY/files/resources/js/core/echo.js ./resources/js/core/
rm ./resources/js/bootstrap.js

echo -e "\nConfigured Laravel-Wave as Laravel Echo implementation."

# * =============
# * Stacks Setup
# * ===========

if [ "$laravel_stack" = "tall" ]; then
  # Alpine.js
  mkdir ./resources/js/packages

  sudo cp -r $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/packages ./resources/js/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/core/alpine.js ./resources/js/core/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/app.js ./resources/js/

  echo -e "\nConfigured ALpine.js framework."

  # Alpine.js Breakpoints
  echo -e "\nConfigured Alpine.js Breakpoints. (check app.blade.php listeners)"

  # Livewire
  php artisan livewire:publish --config --quiet

  rm ./resources/views/welcome.blade.php
  mkdir -p ./resources/views/components/home
  mkdir -p ./resources/views/partials
  sudo cp $LARA_STACKER_DIRECTORY/files/app/Http/Controllers/HomeController.php ./app/Http/Controllers/
  sudo cp $LARA_STACKER_DIRECTORY/files/routes/web.php ./routes/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/home.blade.php ./resources/views/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/components/app.blade.php ./resources/views/components/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/components/home/link.blade.php ./resources/views/components/home/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/partials/fader.blade.php ./resources/views/partials/

  sed -i "s/\"@php artisan package:discover --ansi\"/\"@php artisan package:discover --ansi\",\n            \"@php artisan vendor:publish --force --tag=livewire:assets --ansi\"/g" ./composer.json
  sed -i "s/'layout' => 'layouts.app',/'layout' => 'components.app',/g" ./config/livewire.php
  sed -i "s/'disk' => null,/'disk' => 's3',/g" ./config/livewire.php

  echo -e "\nConfigured Livewire framework."

  # Livewire Hot-Reload
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/vite.config.js ./
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/core/livewire-hot-reload.js ./resources/js/core/
  echo -e "\nVITE_LIVEWIRE_OPT_IN=true" | tee -a ./.env >/dev/null 2>&1

  sed -i "s~<projectName>~$escaped_project_name~g" ./vite.config.js

  echo -e "\nConfigured Livewire Hot-Reload watcher."

  # Blurred Image
  php artisan blurred-image:install --quiet

  echo -e "\nConfigured Blurred Image and Blurhash."

  # Filament Shield
  cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/app/Models/User.php ./app/Models/
  php artisan vendor:publish --tag=filament-shield-config --quiet

  sed -i "s~'navigation_group' => true,~'navigation_group' => false,~g" ./config/filament-shield.php

  php artisan shield:install --fresh --only --quiet >/dev/null 2>&1

  echo -e "\nConfigured Filament Shield for role management page."

  # Filament Admin
  php artisan vendor:publish --tag=filament-config --quiet
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/css/filament.css ./resources/css/

  sed -i "s/\"@php artisan vendor:publish --tag=laravel-assets --ansi --force\"/\"@php artisan vendor:publish --tag=laravel-assets --ansi --force\",\n            \"@php artisan filament:upgrade\"/g" ./composer.json
  sed -i "s/Widgets\\\AccountWidget::class,/\/\/ Widgets\\\AccountWidget::class,/g" ./config/filament.php
  sed -i "s/Widgets\\\FilamentInfoWidget::class,/\/\/ Widgets\\\FilamentInfoWidget::class,/g" ./config/filament.php
  sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/filament.php
  sed -i "s/'should_show_logo' => true,/'should_show_logo' => false,/g" ./config/filament.php
  sed -i "s/'vertical_alignment' => 'top',/'vertical_alignment' => 'bottom',/g" ./config/filament.php
  echo -e "\nFILAMENT_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
  sed -i "s|https://fonts.googleapis.com/css2?family=DM+Sans:ital,wght@0,400;0,500;0,700;1,400;1,500;1,700\&display=swap|https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700\&display=swap|g" ./config/filament.php

  echo -e "\nConfigured Filament Admin (s3, dark mode, and theme)."

  # Filament Forms
  php artisan vendor:publish --tag=forms-config --quiet

  echo -e "FORMS_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
  sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/forms.php

  echo -e "\nConfigured Filament Forms (s3 and dark mode)."

  # Filament Tables
  php artisan vendor:publish --tag=tables-config --quiet

  echo -e "TABLES_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
  sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/tables.php

  echo -e "\nConfigured Filament Tables (s3 and dark mode)."

  # Filament Notifications
  php artisan vendor:publish --tag=notifications-config --quiet

  sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/notifications.php
  sed -i "s/'vertical' => 'top',/'vertical' => 'bottom',/g" ./config/notifications.php

  echo -e "\nConfigured Filament Notifications (dark mode and bottom-right)."
fi

# TODO other stacks...

# * ==========================
# * Opinionated Modifications
# * ========================

cd $PROJECTS_DIRECTORY/$escaped_project_name

if [ "$is_multilingual" == true ]; then
  # Move lang folder to resources folder
  mv ./lang ./resources/

  echo -e "\nMoved lang folder to [resources] folder."

  # Add Arabic helper functions file
  mkdir -p ./app/Services/Support
  sudo cp $LARA_STACKER_DIRECTORY/files/app/Services/Support/functions.php ./app/Services/Support/
  sed -i '0,/"psr-4": {/s//"files": [\n            "app\/Services\/Support\/functions.php"\n        ],\n        "psr-4": {/' ./composer.json

  composer dump-autoload -n --quiet

  sed -i "s/\[config('app.locale')\]/available_locales(withoutEn: true)/g" ./config/filament-spatie-laravel-translatable-plugin.php

  echo -e "\nCreated a helper functions file and registered it in [composer.json]."
fi

# Add an environment variable for password timeout
sed -i "s/'password_timeout' => 10800,/'password_timeout' => config('PASSWORD_TIMEOUT', 10800),/g" ./config/auth.php
sed -i "s/SESSION_LIFETIME=120/SESSION_LIFETIME=120\nPASSWORD_TIMEOUT=10800/g" ./.env

echo -e "\nAdded an environment variable for password timeout."

# Extract an Enumerifier helper trait
mkdir -p ./app/Services/Support/Traits
sudo cp $LARA_STACKER_DIRECTORY/files/app/Services/Support/Traits/Enumerifier.php ./app/Services/Support/Traits/

echo -e "\nExtracted an Enumerifier helper trait."

# Add an environment-user seeder
sudo cp $LARA_STACKER_DIRECTORY/files/database/seeders/DatabaseSeeder.php ./database/seeders/
echo -e "\nENV_USER_NAME=Admin" | tee -a ./.env >/dev/null 2>&1
echo -e "ENV_USER_EMAIL=admin@laravel.com" | tee -a ./.env >/dev/null 2>&1
echo -e "ENV_USER_PASSWORD=password" | tee -a ./.env >/dev/null 2>&1

php artisan db:seed --quiet

echo -e "\nAdded an environment-user for quick generation."

# Updated .gitignore file
sudo cp $LARA_STACKER_DIRECTORY/files/.gitignore ./

echo -e "\nUpdated .gitignore file."

# Copy the opinionated VSC keybindings
if [[ $found_vsc == true && $VSC_KEYBINDINGS == true ]]; then
  sudo cp $LARA_STACKER_DIRECTORY/files/.opinionated/keybindings.json ./.vscode/

  echo -e "\nCopied VSC workspace key-bindings."
fi

# Create a dedicated VSC workspace in Desktop
if [[ $found_vsc == true && $VSC_WORKSPACE == true ]]; then
  cd /home/$USERNAME/Desktop

  sudo cp $LARA_STACKER_DIRECTORY/files/.opinionated/project.code-workspace ./$escaped_project_name.code-workspace

  sudo sed -i "s/<projectName>/$escaped_project_name/g" ./$escaped_project_name.code-workspace
  sudo sed -i "s/<username>/$USERNAME/g" ./$escaped_project_name.code-workspace
  sudo sed -i "s~<projectsDirectory>~$PROJECTS_DIRECTORY~g" ./$escaped_project_name.code-workspace
  sudo sed -i "s/<username>/$USERNAME/g" ./$escaped_project_name.code-workspace

  sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh ./$escaped_project_name.code-workspace

    sudo sed -i "s/<projectName>/$escaped_project_name/g" ./$escaped_project_name.code-workspace
    # sudo sed -i "s~<projectsDirectory>~$PROJECTS_DIRECTORY~g" ./$escaped_project_name.code-workspace
    # sudo sed -i "s/<username>/$USERNAME/g" ./$escaped_project_name.code-workspace

    sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh ./$escaped_project_name.code-workspace

    echo -e "\nCreated a dedicated VSC workspace in Desktop."
  fi
fi

# ! Done

# Update the permissions all around
sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nUpdated directory and file permissions all around."

# Display a success message
echo -e "\nProject created successfully! You can access it at: [https://$escaped_project_name.test].\n"

read -p "Press any key to continue..." whatever

clear
