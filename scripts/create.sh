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
sed -i "s|APP_URL=http://localhost|APP_URL=https://$escaped_project_name.test|g" ./.env

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
composer require --with-all-dependencies -n --quiet league/flysystem-aws-s3-v3:"^3.0" predis/predis laravel/scout spatie/laravel-medialibrary spatie/eloquent-sortable spatie/laravel-sluggable spatie/laravel-tags spatie/laravel-settings spatie/laravel-options blade-ui-kit/blade-icons spatie/laravel-permission qruto/laravel-wave gehrisandro/tailwind-merge-laravel

# TALL Packages...
if [ "$laravel_stack" = "tall" ]; then
  sed -i "s~\"stable\"~\"dev\"~g" ./composer.json
  composer require -n --quiet --with-all-dependencies livewire/livewire:"^3.0@beta" filament/filament:"^3.0-stable" filament/forms:"^3.0-stable" filament/tables:"^3.0-stable" filament/notifications:"^3.0-stable" filament/actions:"^3.0-stable" filament/infolists:"^3.0-stable" filament/widgets:"^3.0-stable" filament/spatie-laravel-media-library-plugin:"^3.0-stable" filament/spatie-laravel-tags-plugin:"^3.0-stable" filament/spatie-laravel-settings-plugin:"^3.0-stable" danharrin/livewire-rate-limiting bezhansalleh/filament-shield:"^3.0@beta" goodm4ven/blurred-image
fi

# Language Packages...
if [ "$is_multilingual" == true ]; then
  filament_translatable=""
  if [ "$laravel_stack" = "tall" ]; then
    filament_translatable="filament/spatie-laravel-translatable-plugin"
  fi
  composer require -n --quiet --with-all-dependencies mcamara/laravel-localization spatie/laravel-translatable $filament_translatable
fi

# * =============
# * NPM Packages
# * ===========

echo -e "\nInstalling NPM packages..."

cd $PROJECTS_DIRECTORY/$escaped_project_name

if [ "$laravel_stack" = "tall" ]; then
  # TALL packages...
  npm install @alpinejs/mask @alpinejs/intersect @alpinejs/focus @alpinejs/collapse @alpinejs/morph @ryangjchandler/alpine-hooks >/dev/null 2>&1

  # Uninstall axios
  npm uninstall axios >/dev/null 2>&1

  # TALL Dev Packages...
  npm install --save-dev @defstudio/vite-livewire-plugin alpinejs-breakpoints >/dev/null 2>&1
fi

# Dev Packages...
npm install --save-dev tailwindcss postcss postcss-import autoprefixer @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio @whiterussianstudio/tailwind-easing >/dev/null 2>&1

# Packages...
npm install @tailwindcss/container-queries tippy.js laravel-wave >/dev/null 2>&1

# ! Currently vulnerable!
# TODO add to the others when stable
# Cypress
npm install --force cypress >/dev/null 2>&1

# * =======================
# * Package Configurations
# * =====================

cd $PROJECTS_DIRECTORY/$escaped_project_name

mkdir -p ./resources/css/packages

# TaliwindCSS
if [ "$laravel_stack" = "tall" ]; then
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/css/app.css ./resources/css/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/css/packages/alpinejs-breakpoints.css ./resources/css/packages/
  sudo cp -r $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/css/filament ./resources/css/
else
  sudo cp $LARA_STACKER_DIRECTORY/files/resources/css/app.css ./resources/css/
fi
sudo cp $LARA_STACKER_DIRECTORY/files/resources/css/packages/tippy.css ./resources/css/packages/
sudo cp $LARA_STACKER_DIRECTORY/files/postcss.config.js ./
sudo cp $LARA_STACKER_DIRECTORY/files/tailwind.config.js ./
sudo cp $LARA_STACKER_DIRECTORY/files/vite.config.js ./

if [ "$is_multilingual" == true ]; then
  sed -i "s~sans: \['Ubuntu', ...defaultTheme.fontFamily.sans\],~sans: \['Ubuntu', ...defaultTheme.fontFamily.sans\],\n                arabic: \['\"Noto Sans Arabic\"', ...defaultTheme.fontFamily.sans\],~g" ./tailwind.config.js
fi

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

if [[ "$OPINIONATED" == true && "$is_multilingual" == true ]]; then
  # Add Arabic helper functions file
  mkdir -p ./app/Services/Support
  sudo cp $LARA_STACKER_DIRECTORY/files/app/Services/Support/functions.php ./app/Services/Support/
  sed -i '0,/"psr-4": {/s//"files": [\n            "app\/Services\/Support\/functions.php"\n        ],\n        "psr-4": {/' ./composer.json

  composer dump-autoload -n --quiet

  echo -e "\nCreated a localization helper functions file and registered it in [composer.json]."
fi

# Install Redis, predis and the facade alias
if [ "$laravel_stack" = "tall" ]; then
  mkdir ./app/Providers/Filament

  if [ "$is_multilingual" == true ]; then
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/app/Providers/MultilingualAdminPanelProvider.php ./app/Providers/Filament/AdminPanelProvider.php
  else
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/app/Providers/AdminPanelProvider.php ./app/Providers/Filament/
  fi

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

rm ./resources/js/bootstrap.js

mkdir ./resources/js/core

sudo cp $LARA_STACKER_DIRECTORY/files/resources/js/core/echo.js ./resources/js/core/

echo -e "\nConfigured Laravel-Wave as Laravel Echo implementation."

# Set up Breeze routes in place
sudo cp $LARA_STACKER_DIRECTORY/files/app/Http/Controllers/HomeController.php ./app/Http/Controllers/
sudo cp $LARA_STACKER_DIRECTORY/files/routes/web.php ./routes/

mv ./resources/views/welcome.blade.php ./resources/views/home.blade.php

echo -e "\nSet up Breeze routes in place."

# * =============
# * Stacks Setup
# * ===========

if [ "$laravel_stack" = "tall" ]; then
  # Alpine.js
  mkdir ./resources/js/packages

  sudo cp -r $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/packages ./resources/js/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/core/alpine-livewire.js ./resources/js/core/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/js/app.js ./resources/js/

  echo -e "\nConfigured Livewire and AlpineJS frameworks."

  # Livewire
  php artisan livewire:publish --config --quiet

  rm -rf ./app/View
  rm -rf ./resources/views/auth
  rm ./resources/views/components/*
  rm -rf ./resources/views/layouts
  rm -rf ./resources/views/profile
  rm ./resources/views/dashboard.blade.php
  rm ./resources/views/home.blade.php
  rm ./routes/auth.php

  mkdir -p ./resources/views/components/home
  mkdir -p ./resources/views/partials

  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/app/Http/Controllers/HomeController.php ./app/Http/Controllers/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/routes/web.php ./routes/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/home.blade.php ./resources/views/
  sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/components/home/link.blade.php ./resources/views/components/home/

  if [ "$OPINIONATED" == true ]; then
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/partials/opinionated-fader.blade.php ./resources/views/partials/fader.blade.php
  else
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/partials/fader.blade.php ./resources/views/partials/
  fi

  if [[ "$OPINIONATED" == true && "$is_multilingual" == true ]]; then
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/components/multilingual-app.blade.php ./resources/views/components/app.blade.php
  else
    sudo cp $LARA_STACKER_DIRECTORY/files/_stubs/tall/resources/views/components/app.blade.php ./resources/views/components/
  fi

  sed -i "s/'layout' => 'components.layouts.app',/'layout' => 'components.app',/g" ./config/livewire.php
  sed -i "s/'disk' => null,/'disk' => 's3',/g" ./config/livewire.php

  echo -e "\nConfigured Livewire framework."

  # Alpine.js Breakpoints
  echo -e "\nConfigured AlpineJS Breakpoints plugin. (Check out the listeners in [app.blade.php])"

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
  php artisan make:filament-theme --quiet >/dev/null 2>&1

  sed -i "s/\"@php artisan package:discover --ansi\"/\"@php artisan package:discover --ansi\",\n            \"@php artisan filament:upgrade\"/g" ./composer.json

  echo -e "\nConfigured Filament admin panel."
fi

# TODO other stacks...

# * ==========================
# * Opinionated Modifications
# * ========================

cd $PROJECTS_DIRECTORY/$escaped_project_name

if [ "$OPINIONATED" == true ]; then
  if [ "$is_multilingual" == true ]; then
    # Move lang folder to resources folder
    mv ./lang ./resources/

    echo -e "\nMoved lang folder to [resources] folder."
  fi

  # Add an environment variable for password timeout
  sed -i "s/'password_timeout' => 10800,/'password_timeout' => config('PASSWORD_TIMEOUT', 10800),/g" ./config/auth.php
  sed -i "s/SESSION_LIFETIME=120/SESSION_LIFETIME=120\nPASSWORD_TIMEOUT=10800/g" ./.env

  echo -e "\nAdded an environment variable for password timeout."

  # Extract an Enumerifier helper trait
  mkdir ./app/Enums
  mkdir -p ./app/Services/Support/Traits

  sudo cp $LARA_STACKER_DIRECTORY/files/app/Services/Support/Traits/Enumerifier.php ./app/Services/Support/Traits/
  sudo cp $LARA_STACKER_DIRECTORY/files/app/Enums/Example.php ./app/Enums/

  echo -e "\nExtracted an Example enum with an Enumerifier helper trait."

  # Add an environment-user seeder
  sudo cp $LARA_STACKER_DIRECTORY/files/database/seeders/DatabaseSeeder.php ./database/seeders/
  echo -e "\nENV_USER_NAME=Admin" | tee -a ./.env >/dev/null 2>&1
  echo -e "ENV_USER_EMAIL=admin@laravel.com" | tee -a ./.env >/dev/null 2>&1
  echo -e "ENV_USER_PASSWORD=password" | tee -a ./.env >/dev/null 2>&1

  php artisan db:seed --quiet

  echo -e "\nAdded an environment-user for quick generation."

  # Prettier config
  sudo cp $LARA_STACKER_DIRECTORY/files/.opinionated/.prettierrc ./.prettierrc

  echo -e "\nCopied Prettier configuration file."

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
    sudo sed -i "s~<projectsDirectory>~$PROJECTS_DIRECTORY~g" ./$escaped_project_name.code-workspace

    sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh ./$escaped_project_name.code-workspace

    echo -e "\nCreated a dedicated VSC workspace in Desktop."
  fi
fi

# ! Done

cd $PROJECTS_DIRECTORY/$escaped_project_name

# Update the permissions all around
sudo $LARA_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nUpdated directory and file permissions all around."

# Build the front-end assets
composer update -n --quiet >/dev/null 2>&1
npm update >/dev/null 2>&1
npm run build >/dev/null 2>&1

echo -e "\nFront-end assets compiled successfully and everything is up-to-date."

# Display a success message
echo -e "\nProject created successfully! You can access it at: [https://$escaped_project_name.test].\n"

read -p "Press any key to continue..." whatever

clear
