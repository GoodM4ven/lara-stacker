#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "\nPlease run the script as super-user (sudo)."
  exit
fi

# Confirm if setup script isn't run
if [ ! -e "$PWD/done-setup" ]; then
  echo ""
  read -p "Setup script isn't run yet. Are you sure you want to continue? (y/n) " confirmation

  case "$confirmation" in
    n|N|no|NO ) 
      echo -e "\nAborting..."
      exit 1
      ;;
  esac
fi

# Check if VSC is installed
found_vsc=false
if command -v code &>/dev/null; then
  found_vsc=true
fi

# Beginning Indicator
echo -e "\n============================"
echo -e "=- TALL STACKER |> CREATE -="
echo -e "============================\n"

# Get environment variables and defaults
source $PWD/.env

# Get the project name from the user
read -p "Enter the project name: " project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# Check if the project directory already exists
if [ -d "$PROJECTS_DIRECTORY/$escaped_project_name" ]; then
  echo -e "\nProject folder already exists. Cancelling...\n"
  exit 1
fi

# ? Navigate to the projects folder
cd $PROJECTS_DIRECTORY/

echo ""

# Create the Laravel project in the projects directory
echo -e "Installing the project via Composer; a bit of patience..."

composer create-project --prefer-dist laravel/laravel $escaped_project_name -n --quiet

# Generate an SSL certificate via mkcert
sudo su - $USERNAME
cd /home/$USERNAME/
mkcert $escaped_project_name.test 2>/dev/null
sudo mkdir $PROJECTS_DIRECTORY/$escaped_project_name/certs
sudo mv ./$escaped_project_name.test.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
sudo mv ./$escaped_project_name.test-key.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
sudo su

echo -e "\nGenerated SSL certificate via mkcert..."

# Add an entry for the site to the /etc/hosts file
echo -e "127.0.0.1 $escaped_project_name.test" | sudo tee -a /etc/hosts > /dev/null

echo -e "\nAdded the site to /etc/hosts file..."

# ? Navigate to the project's directory
cd $PROJECTS_DIRECTORY/$escaped_project_name

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

sed -i "s/APP_NAME=Laravel/APP_NAME=\"$project_name\"/g" ./.env
sed -i "s|APP_URL=http://localhost|APP_URL=https://$escaped_project_name.test\nAPP_LOCALES=ar,en|g" ./.env

echo -e "\nCreated and activated the site's Apache config file..."

# Generate a MySQL database if doesn't exit
project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$project_db_name/g" ./.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" ./.env

if mysql -u root -p$DB_PASSWORD -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$project_db_name'" 2> /dev/null | grep "$project_db_name" > /dev/null; then
  echo -e "\nMySQL database $project_db_name already exists!"
else
  mysql -u root -p$DB_PASSWORD -e "CREATE DATABASE $project_db_name;" 2> /dev/null
  echo -e "\nCreated $project_db_name MySQL database..."
fi

# ? Install all Composer packages right here
echo -e "\nInstalling all Composer packages; please be patient..."

composer require --dev laravel/telescope pestphp/pest pestphp/pest-plugin-faker pestphp/pest-plugin-laravel pestphp/pest-plugin-livewire laravel-lang/lang --with-all-dependencies -n --quiet

composer require "league/flysystem-aws-s3-v3:^3.0" livewire/livewire qruto/laravel-wave predis/predis mcamara/laravel-localization laravel/scout "spatie/laravel-medialibrary:^10.0.0" filament/filament:"^2.0" filament/forms:"^2.0" filament/tables:"^2.0" filament/notifications:"^2.0" filament/spatie-laravel-media-library-plugin:"^2.0" spatie/eloquent-sortable spatie/laravel-sluggable spatie/laravel-translatable filament/spatie-laravel-translatable-plugin:"^2.0" spatie/laravel-tags filament/spatie-laravel-tags-plugin:"^2.0" spatie/laravel-settings:"^2.2" filament/spatie-laravel-settings-plugin:"^2.0" spatie/laravel-options blade-ui-kit/blade-icons danharrin/livewire-rate-limiting goodm4ven/blurred-image --with-all-dependencies -n --quiet

# ? Install all NPM packages right here
echo -e "\nInstalling all NPM packages; please stay patient...!"

npm install alpinejs @alpinejs/mask @alpinejs/intersect @alpinejs/persist @alpinejs/focus @alpinejs/collapse @alpinejs/morph laravel-wave >/dev/null 2>&1

npm install -D tailwindcss postcss autoprefixer @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio @tailwindcss/line-clamp @tailwindcss/container-queries @defstudio/vite-livewire-plugin tippy.js @awcodes/alpine-floating-ui alpinejs-breakpoints >/dev/null 2>&1

npm uninstall axios >/dev/null 2>&1

# Set up launch.json for debugging
mkdir .vscode
sudo cp $TALL_STACKER_DIRECTORY/files/.vscode/launch.json ./.vscode/

sed -i "s~\[projectsDirectory\]~$PROJECTS_DIRECTORY~g" ./.vscode/launch.json
sed -i "s~\[projectName\]~$escaped_project_name~g" ./.vscode/launch.json

echo -e "\nConfigured VSC debug settings for Xdebug support..."

# Updated .gitignore file
sudo cp $TALL_STACKER_DIRECTORY/files/.gitignore ./

echo -e "\nUpdated .gitignore file..."

# Move lang folder to resources folder
php artisan lang:publish --quiet
mv ./lang ./resources/

echo -e "\nPublished the [lang] folder to [resources] folder..."

# Add an environment variable for password timeout
sed -i "s/'password_timeout' => 10800,/'password_timeout' => config('PASSWORD_TIMEOUT', 10800),/g" ./config/auth.php
sed -i "s/SESSION_LIFETIME=120/SESSION_LIFETIME=120\nPASSWORD_TIMEOUT=10800/g" ./.env

echo -e "\nAdded an environment variable for password timeout..."

# Install Redis, predis and the facade alias
sudo cp $TALL_STACKER_DIRECTORY/files/app/Providers/FilamentServiceProvider.php ./app/Providers/
sudo cp $TALL_STACKER_DIRECTORY/files/config/app.php ./config/

sed -i "s/REDIS_HOST=127.0.0.1/REDIS_CLIENT=predis\nREDIS_HOST=127.0.0.1/g" ./.env

echo -e "\nInstalled Redis, predis and the Redis facade in the project..."

# Set up a MinIO storage
cd /home/$USERNAME/.config/minio/data/
minio-client mb --region=us-east-1 $escaped_project_name >/dev/null 2>&1

sudo su - $USERNAME
cd /home/$USERNAME/
minio-client anonymous set public myminio/$escaped_project_name >/dev/null 2>&1
sudo su

sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh /home/$USERNAME/.config/minio/data/$escaped_project_name

cd $PROJECTS_DIRECTORY/$escaped_project_name

sed -i "s/FILESYSTEM_DISK=local/FILESYSTEM_DISK=s3/g" ./.env
sed -i "s/AWS_ACCESS_KEY_ID=/AWS_ACCESS_KEY_ID=minioadmin/g" ./.env
sed -i "s/AWS_SECRET_ACCESS_KEY=/AWS_SECRET_ACCESS_KEY=minioadmin/g" ./.env
sed -i "s/AWS_BUCKET=/AWS_BUCKET=$escaped_project_name/g" ./.env
sed -i "s|AWS_USE_PATH_STYLE_ENDPOINT=false|AWS_ENDPOINT=http://localhost:9000\nAWS_URL=http://localhost:9000/$escaped_project_name\nAWS_USE_PATH_STYLE_ENDPOINT=true|g" ./.env

echo -e "\nSet up a MinIO storage for the project..."

# Laravel Localization
php artisan vendor:publish --provider="Mcamara\LaravelLocalization\LaravelLocalizationServiceProvider" --quiet

sudo cp $TALL_STACKER_DIRECTORY/files/app/Http/Kernel.php ./app/Http/
sudo cp $TALL_STACKER_DIRECTORY/files/config/laravellocalization.php ./config/
php artisan lang:add ar --quiet

echo -e "\nInstalled Laravel Localization package and enabled AR & EN locales..."

# Add helper functions file
mkdir -p ./app/Services/Support
sudo cp $TALL_STACKER_DIRECTORY/files/app/Services/Support/functions.php ./app/Services/Support/
sed -i '0,/"psr-4": {/s//"files": [\n            "app\/Services\/Support\/functions.php"\n        ],\n        "psr-4": {/' ./composer.json

composer dump-autoload -n --quiet

echo -e "\nCreated a helper functions file and registered it in [composer.json]..."

# Laravel Pest
sudo cp $TALL_STACKER_DIRECTORY/files/tests/Pest.php ./tests/
sudo cp $TALL_STACKER_DIRECTORY/files/tests/Feature/PestExampleTest.php ./tests/Feature/
sudo cp $TALL_STACKER_DIRECTORY/files/tests/Unit/PestExampleTest.php ./tests/Unit/

echo -e "\nInstalled and configured Laravel Pest for testing..."

# Modify the TrustProxies middleware to work with Expose
sed -i "s/protected \$proxies;/protected \$proxies = '*';/g" ./app/Http/Middleware/TrustProxies.php

echo -e "\nTrusted all proxies for Expose compatibility..."

# TaliwindCSS
sudo cp $TALL_STACKER_DIRECTORY/files/resources/css/app.css ./resources/css/
sudo cp $TALL_STACKER_DIRECTORY/files/postcss.config.js ./
sudo cp $TALL_STACKER_DIRECTORY/files/tailwind.config.js ./

echo -e "\nInstalled TailwindCSS framework..."

# Add site references to workspace settings
if [[ $found_vsc == true ]]; then
  workspace="/home/$USERNAME/Code/Workspaces/tall.code-workspace"

  sed '/^\s*\/\// d' "$workspace" > tmp_no_comments.json
  jq --arg path "$PROJECTS_DIRECTORY/$escaped_project_name" '.folders += [{"path": $path}] | .settings["tailwindCSS.experimental.configFile"] += {($path + "/tailwind.config.js"): ($path + "/**")}' tmp_no_comments.json > tmp.json && mv tmp.json "$workspace"
  rm tmp_no_comments.json

  echo -e "\nAdded the site references to the VSC workspace settings..."
fi

# Alpine.js
mkdir ./resources/js/core
mkdir ./resources/js/packages

sudo cp -r $TALL_STACKER_DIRECTORY/files/resources/js/packages ./resources/js/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/js/core/alpine.js ./resources/js/core/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/js/app.js ./resources/js/

echo -e "\nInstalled ALpine.js framework..."

# Alpine.js Breakpoints
echo -e "\nInstalled Alpine.js Breakpoints (check app.blade.php listeners)..."

# TODO needs testing
# Laravel-Wave
php artisan vendor:publish --tag="wave-config" --quiet

sed -i "s/BROADCAST_DRIVER=log/BROADCAST_DRIVER=redis/g" ./.env
rm ./resources/js/bootstrap.js
sudo cp $TALL_STACKER_DIRECTORY/files/resources/js/core/echo.js ./resources/js/core/

echo -e "\nInstalled Laravel-Wave for Laravel Echo implementation..."

# Livewire
php artisan livewire:publish --config --quiet

rm ./resources/views/welcome.blade.php
mkdir -p ./resources/views/components/home
mkdir -p ./resources/views/partials
sudo cp -r $TALL_STACKER_DIRECTORY/files/public/build ./public/
sudo cp $TALL_STACKER_DIRECTORY/files/app/Http/Controllers/HomeController.php ./app/Http/Controllers/
sudo cp $TALL_STACKER_DIRECTORY/files/routes/web.php ./routes/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/views/home.blade.php ./resources/views/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/views/components/app.blade.php ./resources/views/components/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/views/components/home/link.blade.php ./resources/views/components/home/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/views/partials/fader.blade.php ./resources/views/partials/

sed -i "s/\"@php artisan package:discover --ansi\"/\"@php artisan package:discover --ansi\",\n            \"@php artisan vendor:publish --force --tag=livewire:assets --ansi\"/g" ./composer.json
sed -i "s/'layout' => 'layouts.app',/'layout' => 'components.app',/g" ./config/livewire.php
sed -i "s/'disk' => null,/'disk' => 's3',/g" ./config/livewire.php

echo -e "\nInstalled Livewire framework..."

# Livewire Hot-Reload
sudo cp $TALL_STACKER_DIRECTORY/files/vite.config.js ./
sudo cp $TALL_STACKER_DIRECTORY/files/resources/js/core/livewire-hot-reload.js ./resources/js/core/
echo -e "\nVITE_LIVEWIRE_OPT_IN=true" | tee -a ./.env >/dev/null 2>&1

sed -i "s~<projectName>~$escaped_project_name~g" ./vite.config.js

echo -e "\nInstalled Livewire Hot-Reload watcher..."

# Blade Icons
mkdir -p ./resources/svgs/custom
sudo cp $TALL_STACKER_DIRECTORY/files/config/blade-icons.php ./config/
sudo cp -r $TALL_STACKER_DIRECTORY/files/resources/svgs/general ./resources/svgs/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/svgs/custom/laravel.svg ./resources/svgs/custom/

echo -e "\nInstalled Blade Icons and set up Heroicons as the 'general' set..."

# Laravel Telescope
php artisan telescope:install --quiet

php artisan migrate --quiet

sudo cp $TALL_STACKER_DIRECTORY/files/app/Providers/AppServiceProvider.php ./app/Providers/
sed -i "s~\"dont-discover\": \[\]~\"dont-discover\": \[\n                \"laravel/telescope\"\n            \]~g" ./composer.json
echo -e "\nTELESCOPE_ENABLED=true" | tee -a ./.env >/dev/null 2>&1

echo -e "\nInstalled Laravel Telescope for request debugging..."

# Laravel Scout
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider" --quiet

echo -e "\nSCOUT_DRIVER=database" | tee -a ./.env >/dev/null 2>&1

echo -e "\nInstalled Laravel Scout for search optimization..."

# Laravel Media Library
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="migrations" --quiet
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="config" --quiet

php artisan migrate --quiet

sed -i "s~'CacheControl' => 'max-age=604800',~'CacheControl' => 'max-age=604800',\n            'visibility' => 'public',~g" ./config/media-library.php

echo -e "\nMEDIA_DISK=s3" | tee -a ./.env >/dev/null 2>&1

echo -e "\nInstalled and configured Laravel Media Library to work with MinIO..."

# Blurred Image
php artisan blurred-image:install --quiet

echo -e "\nInstalled Blurred Image and Blurhash..."

# Eloquent Sortable
php artisan vendor:publish --tag=eloquent-sortable-config --quiet

sed -i "s/'order_column',/'sorting_order',/g" ./config/eloquent-sortable.php

echo -e "\nInstalled Eloquent Sortable and set 'sorting_order' as the default column..."

# Laravel Sluggable
echo -e "\nInstalled Laravel Sluggable..."

# Laravel Translatable
php artisan vendor:publish --tag=filament-spatie-laravel-translatable-plugin-config --quiet

sed -i "s/\[config('app.locale')\]/available_locales(withoutEn: true)/g" ./config/filament-spatie-laravel-translatable-plugin.php

echo -e "\nInstalled Laravel Translatable..."

# Laravel Tags
php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-migrations" --quiet
php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-config" --quiet

php artisan migrate --quiet

echo -e "\nInstalled Laravel Tags..."

# Laravel Options
php artisan vendor:publish --tag="options-config" --quiet

mkdir -p ./app/Services/Support/Traits
sudo cp $TALL_STACKER_DIRECTORY/files/app/Services/Support/Traits/Enumerifier.php ./app/Services/Support/Traits/

echo -e "\nInstalled Laravel Options and extracted an Enumerifier helper trait..."


# TODO rework and ensure User model is copied here instead
# Laravel Permission
# php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --quiet
# php artisan vendor:publish --tag=filament-shield-config --quiet
# php artisan shield:install --fresh --only --quiet

# sed -i "s~\/\/~return true;~g" ./app/Policies/RolePolicy.php
# sed -i "s~'navigation_group' => true,~'navigation_group' => false,~g" ./config/filament-shield.php

# echo -e "\nInstalled Laravel Permission and Filament Shield for role management page..."

# Laravel Settings
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="migrations" --quiet
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="settings" --quiet
php artisan migrate --quiet

echo -e "\nInstalled Laravel Settings..."

# Filament Admin
php artisan vendor:publish --tag=filament-config --quiet
sudo cp $TALL_STACKER_DIRECTORY/files/app/Models/User.php ./app/Models/
sudo cp $TALL_STACKER_DIRECTORY/files/resources/css/filament.css ./resources/css/

sed -i "s/\"@php artisan vendor:publish --tag=laravel-assets --ansi --force\"/\"@php artisan vendor:publish --tag=laravel-assets --ansi --force\",\n            \"@php artisan filament:upgrade\"/g" ./composer.json
sed -i "s/Widgets\\\AccountWidget::class,/\/\/ Widgets\\\AccountWidget::class,/g" ./config/filament.php
sed -i "s/Widgets\\\FilamentInfoWidget::class,/\/\/ Widgets\\\FilamentInfoWidget::class,/g" ./config/filament.php
sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/filament.php
sed -i "s/'should_show_logo' => true,/'should_show_logo' => false,/g" ./config/filament.php
sed -i "s/'vertical_alignment' => 'top',/'vertical_alignment' => 'bottom',/g" ./config/filament.php
echo -e "\nFILAMENT_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
sed -i "s|https://fonts.googleapis.com/css2?family=DM+Sans:ital,wght@0,400;0,500;0,700;1,400;1,500;1,700\&display=swap|https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700\&display=swap|g" ./config/filament.php

echo -e "\nInstalled Filament Admin (s3, dark mode, and theme)..."

# Filament Forms
php artisan vendor:publish --tag=forms-config --quiet

echo -e "FORMS_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/forms.php

echo -e "\nInstalled Filament Forms (s3 and dark mode)..."

# Filament Tables
php artisan vendor:publish --tag=tables-config --quiet

echo -e "TABLES_FILESYSTEM_DRIVER=s3" | tee -a ./.env >/dev/null 2>&1
sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/tables.php

echo -e "\nInstalled Filament Tables (s3 and dark mode)..."

# Filament Notifications
php artisan vendor:publish --tag=notifications-config --quiet

sed -i "s/'dark_mode' => false,/'dark_mode' => true,/g" ./config/notifications.php
sed -i "s/'vertical' => 'top',/'vertical' => 'bottom',/g" ./config/notifications.php

echo -e "\nInstalled Filament Notifications (dark mode and bottom-right)..."

# Add an environment-user seeder
sudo cp $TALL_STACKER_DIRECTORY/files/database/seeders/DatabaseSeeder.php ./database/seeders/
echo -e "\nENV_USER_NAME=Admin" | tee -a ./.env >/dev/null 2>&1
echo -e "ENV_USER_EMAIL=admin@laravel.com" | tee -a ./.env >/dev/null 2>&1
echo -e "ENV_USER_PASSWORD=password" | tee -a ./.env >/dev/null 2>&1

php artisan db:seed --quiet

echo -e "\nAdded an environment-user for quick generation..."

# Set the RouteServiceProvider home's to '/'
sed -i "s/public const HOME = '\/home';/public const HOME = '\/';/g" ./app/Providers/RouteServiceProvider.php

echo -e "\nSet the RouteServiceProvider home's to '/' route..."

# ! Keep this at the very end; after all file modifications.
# Update the permissions all around
sudo $TALL_STACKER_DIRECTORY/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nUpdated directory and file permissions all around..."

# # Open the project directory with VSC if available
# if [[ $open_vsc == true ]]; then
#   echo -e "\nOpening the project with VSC..."
  
#   code $PROJECTS_DIRECTORY/$escaped_project_name/
# fi

# Display a success message
echo -e "\nProject created successfully! You can access it at: [https://$escaped_project_name.test].\n"
# echo -e "\nNote: File permissions through VSC need about a minute or two to kick in; after indexing via PHP Intelephense extension.\n"
