#!/bin/bash

clear

# Status indicator
echo -e "-=|[ Lara-Stacker |> CREATE ]|=-\n"

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

# Confirm if setup script isn't run
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

# * =================
# * Collecting Input
# * ===============

# Get the project name from the user
echo -ne "Enter the project name: " >&3
read project_name

escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
escaped_project_name=${escaped_project_name// /}

# Cancel if the project directory already exists
if [ -d "$PROJECTS_DIRECTORY/$escaped_project_name" ]; then
    prompt "\nProject folder already exists!" "Project creation cancelled."
fi

# Get the stack choice
while true; do
    echo -ne "Enter the Laravel stack (tall, tvil, tvil-ssr, tril, tril-ssr, api): " >&3
    read laravel_stack

    case "$laravel_stack" in
    tall)
        break
        ;;
    tvil|tvil-ssr|tril|tril-ssr|api)
        echo "The stack script is not ready yet..." >&3
        ;;
    *)
        echo "Unknown stack!" >&3
        ;;
    esac
done

# Get whether the project is localized or not
echo -ne "Is the project localized? (y/n) " >&3
read is_localized
if [ "$is_localized" = "n" ] || [ "$is_localized" = "N" ] || [ "$is_localized" = "no" ] || [ "$is_localized" = "NO" ]; then
    is_localized=false
else
    is_localized=true
fi

# Get the pest choice
echo -ne "Do you want to use Laravel Pest over PHPUnit for testing? (y/n) " >&3
read use_pest
if [ "$use_pest" = "n" ] || [ "$use_pest" = "N" ] || [ "$use_pest" = "no" ] || [ "$use_pest" = "NO" ]; then
    use_pest=false
else
    use_pest=true
fi

# * =================
# * Project Creation
# * ===============

# Create the Laravel project in the projects directory
echo -e "\nInstalling the project via Composer..." >&3

cd $PROJECTS_DIRECTORY/
composer create-project --prefer-dist laravel/laravel $escaped_project_name -n $conditional_quiet

sudo $lara_stacker_dir/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

# Generate an SSL certificate via mkcert
sudo -i -u $USERNAME bash <<EOF
cd /home/$USERNAME/
if $cancel_suppression; then
    mkcert $escaped_project_name.test 2>&1
else
    mkcert $escaped_project_name.test 2>&1 >/dev/null
fi
mkdir $PROJECTS_DIRECTORY/$escaped_project_name/certs
mv ./$escaped_project_name.test.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
mv ./$escaped_project_name.test-key.pem $PROJECTS_DIRECTORY/$escaped_project_name/certs/
EOF

echo -e "\nGenerated SSL certificate via mkcert." >&3

# Add an entry for the site to the /etc/hosts file
echo -e "127.0.0.1 $escaped_project_name.test" | sudo tee -a /etc/hosts > /dev/null

echo -e "\nAdded the site to [/etc/hosts] file." >&3

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

sudo a2ensite -q $escaped_project_name

sudo service apache2 restart

cd $PROJECTS_DIRECTORY/$escaped_project_name

sed -i "s/APP_NAME=Laravel/APP_NAME=\"$project_name\"/g" ./.env
sed -i "s|APP_URL=http://localhost|APP_URL=https://$escaped_project_name.test|g" ./.env

echo -e "\nCreated and activated the site's Apache config file." >&3

# Generate a MySQL database if doesn't exit
project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

cd $PROJECTS_DIRECTORY/$escaped_project_name
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$project_db_name/g" ./.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" ./.env

export MYSQL_PWD=$DB_PASSWORD
if mysql -u root -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$project_db_name'" | grep "$project_db_name" > /dev/null; then
    echo -e "\nMySQL database '$project_db_name' already exists!" >&3
else
    mysql -u root -e "CREATE DATABASE $project_db_name;"
    echo -e "\nCreated '$project_db_name' MySQL database." >&3
fi

# Set up launch.json for debugging (Xdebug)
mkdir $PROJECTS_DIRECTORY/$escaped_project_name/.vscode
cd $PROJECTS_DIRECTORY/$escaped_project_name/.vscode

sudo cp $lara_stacker_dir/files/.vscode/launch.json ./

sed -i "s~\[projectsDirectory\]~$PROJECTS_DIRECTORY~g" ./launch.json
sed -i "s~\[projectName\]~$escaped_project_name~g" ./launch.json

echo -e "\nConfigured VSC debug settings for Xdebug support." >&3

# Set up a MinIO storage
cd /home/$USERNAME/.config/minio/data/
minio-client mb --region=us-east-1 $escaped_project_name

sudo -i -u $USERNAME bash <<EOF
cd /home/$USERNAME/
minio-client anonymous set public myminio/$escaped_project_name
EOF

sudo $lara_stacker_dir/scripts/helpers/permit.sh /home/$USERNAME/.config/minio/data/$escaped_project_name

cd $PROJECTS_DIRECTORY/$escaped_project_name
sed -i "s/FILESYSTEM_DISK=local/FILESYSTEM_DISK=s3/g" ./.env
sed -i "s/AWS_ACCESS_KEY_ID=/AWS_ACCESS_KEY_ID=minioadmin/g" ./.env
sed -i "s/AWS_SECRET_ACCESS_KEY=/AWS_SECRET_ACCESS_KEY=minioadmin/g" ./.env
sed -i "s/AWS_BUCKET=/AWS_BUCKET=$escaped_project_name/g" ./.env
sed -i "s|AWS_USE_PATH_STYLE_ENDPOINT=false|AWS_ENDPOINT=http://localhost:9000\nAWS_URL=http://localhost:9000/$escaped_project_name\nAWS_USE_PATH_STYLE_ENDPOINT=true|g" ./.env

echo -e "\nSet up a MinIO storage for the project." >&3

# * ===============================
# * Composer Packages Installation
# * =============================

echo -e "\nInstalling Composer packages..." >&3

cd $PROJECTS_DIRECTORY/$escaped_project_name

# Breeze package
composer require --dev laravel/breeze laravel/telescope --with-all-dependencies -n $conditional_quiet

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
php artisan breeze:install $stack --dark $ssr $pest $conditional_quiet

# Pest framework
if [ "$use_pest" == true ]; then
    livewire_plugin=""
    if [ "$laravel_stack" = "tall" ]; then
        livewire_plugin="pestphp/pest-plugin-livewire"
    fi
    composer require --dev -n pestphp/pest-plugin-watch pestphp/pest-plugin-faker $livewire_plugin $conditional_quiet
fi

# laravel-lang (dev)
if [ "$is_localized" == true ]; then
    composer require --dev -n laravel-lang/lang $conditional_quiet
fi

# Dev Packages
composer require laracasts/cypress --dev -n $conditional_quiet

# Non-dev Packages...
composer require --with-all-dependencies -n league/flysystem-aws-s3-v3:"^3.0" predis/predis laravel/scout spatie/laravel-medialibrary spatie/laravel-data spatie/eloquent-sortable spatie/laravel-sluggable spatie/laravel-tags spatie/laravel-settings blade-ui-kit/blade-icons spatie/laravel-permission qruto/laravel-wave gehrisandro/tailwind-merge-laravel artesaos/seotools $conditional_quiet

# TALL Packages...
if [ "$laravel_stack" = "tall" ]; then
    composer require -n --with-all-dependencies livewire/livewire filament/filament:"^3.0-stable" filament/forms:"^3.0-stable" filament/tables:"^3.0-stable" filament/notifications:"^3.0-stable" filament/actions:"^3.0-stable" filament/infolists:"^3.0-stable" filament/widgets:"^3.0-stable" filament/spatie-laravel-media-library-plugin:"^3.0-stable" filament/spatie-laravel-tags-plugin:"^3.0-stable" filament/spatie-laravel-settings-plugin:"^3.0-stable" danharrin/livewire-rate-limiting bezhansalleh/filament-shield:"^3.0@beta" awcodes/overlook goodm4ven/blurred-image $conditional_quiet
fi

# Localization Packages...
if [ "$is_localized" == true ]; then
    filament_localization_packages=""
    if [ "$laravel_stack" = "tall" ]; then
        filament_localization_packages="filament/spatie-laravel-translatable-plugin kenepa/translation-manager"
    fi
    composer require -n $conditional_quiet --with-all-dependencies mcamara/laravel-localization spatie/laravel-translatable $filament_localization_packages
fi

# * ==========================
# * NPM Packages Installation
# * ========================

echo -e "\nInstalling NPM packages..." >&3

cd $PROJECTS_DIRECTORY/$escaped_project_name

if [ "$laravel_stack" = "tall" ]; then
    # TALL packages...
    npm install @alpinejs/mask @alpinejs/intersect @alpinejs/focus @alpinejs/collapse @alpinejs/morph @ryangjchandler/alpine-hooks @ralphjsmit/alpine-animate

    # Uninstall axios
    npm uninstall axios

    # TALL Dev Packages...
    npm install --save-dev @defstudio/vite-livewire-plugin alpinejs-breakpoints
fi

# Dev Packages...
npm install --save-dev tailwindcss postcss postcss-import autoprefixer @tailwindcss/typography @tailwindcss/forms @tailwindcss/aspect-ratio @whiterussianstudio/tailwind-easing

# Packages...
npm install @tailwindcss/container-queries tippy.js laravel-wave @formkit/auto-animate

# ! Currently vulnerable!
# TODO add to the others when stable
# Cypress
sudo $lara_stacker_dir/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

sudo -i -u $USERNAME bash <<EOF
if $cancel_suppression; then
    mkcert npm install --force --save-dev cypress 2>&1
else
    mkcert npm install --force --save-dev cypress 2>&1 >/dev/null
fi
EOF

# * =======================
# * Package Configurations
# * =====================

cd $PROJECTS_DIRECTORY/$escaped_project_name

# Running migrations initially
php artisan migrate $conditional_quiet

echo -e "\nRan the migrations initially." >&3

# TaliwindCSS framework
mkdir -p ./resources/css/packages

if [ "$laravel_stack" = "tall" ]; then
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/css/app.css ./resources/css/
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/css/packages/alpinejs-breakpoints.css ./resources/css/packages/
else
    sudo cp $lara_stacker_dir/files/resources/css/app.css ./resources/css/
fi
sudo cp $lara_stacker_dir/files/resources/css/packages/tippy.css ./resources/css/packages/
sudo cp $lara_stacker_dir/files/postcss.config.js ./
sudo cp $lara_stacker_dir/files/tailwind.config.js ./
sudo cp $lara_stacker_dir/files/vite.config.js ./

if [ "$is_localized" == true ]; then
    sed -i "s~sans: \['Ubuntu', ...defaultTheme.fontFamily.sans\],~sans: \['Ubuntu', ...defaultTheme.fontFamily.sans\],\n                arabic: \['\"Noto Sans Arabic\"', ...defaultTheme.fontFamily.sans\],~g" ./tailwind.config.js
fi

php artisan vendor:publish --provider="TailwindMerge\Laravel\TailwindMergeServiceProvider" $conditional_quiet

echo -e "\nConfigured TailwindCSS framework and TailwindMerge package." >&3

# Cypress framework
php artisan cypress:boilerplate $conditional_quiet

echo -e "\nConfigured front-end testing with Cypress." >&3

# Laravel Data package
php artisan vendor:publish --provider="Spatie\LaravelData\LaravelDataServiceProvider" --tag="data-config" $conditional_quiet

echo -e "\nConfigured Laravel Data package." >&3

# SEOTools package
php artisan vendor:publish --provider="Artesaos\SEOTools\Providers\SEOToolsServiceProvider" $conditional_quiet

echo -e "\nConfigured SEOTools package." >&3

# Blade Icons package
mkdir ./resources/svgs

php artisan vendor:publish --provider="BladeUI\Icons\BladeIconsServiceProvider" $conditional_quiet
sed -i "s/^[ \t]*'default' => \[/        'overridden' => [/" ./config/blade-icons.php
sed -i "/'sets' => \[/a \
\\
\\n\
        'default' => [\n\
            'path' => 'resources/svgs',\n\
            'disk' => '',\n\
            'prefix' => 'icon',\n\
            'fallback' => '',\n\
            'class' => '',\n\
            'attributes' => [],\n\
        ]," ./config/blade-icons.php

sudo cp $lara_stacker_dir/files/resources/svgs/laravel.svg ./resources/svgs/

echo -e "\nConfigured Blade Icons in [resources/svgs] directory." >&3

if [[ "$OPINIONATED" == true && "$is_localized" == true ]]; then
    # Add localization helpers functions file
    mkdir -p ./app/Services/Support
    sudo cp $lara_stacker_dir/files/app/Services/Support/localization_helpers.php ./app/Services/Support/
    sed -i '0,/"psr-4": {/s//"files": [\n            "app\/Services\/Support\/localization_helpers.php"\n        ],\n        "psr-4": {/' ./composer.json

    composer dump-autoload -n $conditional_quiet

    echo -e "\nCreated a localization helpers file and registered it in [composer.json]." >&3
fi

# Added providers and facades to [app] config file
perl -0777 -i -pe 's|(\s*/\*\n\s+\*\s+Package Service Providers\.\.\.\n\s+\*/)|$1\n        Artesaos\\SEOTools\\Providers\\SEOToolsServiceProvider::class,|g' ./config/app.php

sed -i "/\/\/ 'Example' => App\\\\Facades\\\\Example::class,/c\\
        'Redis' => Illuminate\\\\Support\\\\Facades\\\\Redis::class,\\
        'SEO' => Artesaos\\\\SEOTools\\\\Facades\\\\SEOTools::class," ./config/app.php

if [ "$laravel_stack" = "tall" ]; then
    mkdir ./app/Providers/Filament
    sudo cp ./vendor/filament/support/stubs/AdminPanelProvider.stub ./app/Providers/Filament/AdminPanelProvider.php

    perl -0777 -i -pe 's|(\s*/\*\n\s+\*\s+Package Service Providers\.\.\.\n\s+\*/)|$1\n        App\\Providers\\Filament\\AdminPanelProvider::class,|g' ./config/app.php

    sed -i '/use Filament\\Http\\Middleware\\Authenticate;/c\use Awcodes\\Overlook\\OverlookPlugin;\
use Awcodes\\Overlook\\Widgets\\OverlookWidget;\
use BezhanSalleh\\FilamentShield\\FilamentShieldPlugin;\
use Filament\\Http\\Middleware\\Authenticate;' ./app/Providers/Filament/AdminPanelProvider.php

    if [ "$is_localized" == true ]; then
        sed -i '/use Filament\\PanelProvider;/a\use Filament\\SpatieLaravelTranslatablePlugin;' ./app/Providers/Filament/AdminPanelProvider.php
        sed -i '/use Illuminate\\View\\Middleware\\ShareErrorsFromSession;/a\use Kenepa\\TranslationManager\\TranslationManagerPlugin;' ./app/Providers/Filament/AdminPanelProvider.php
    fi

    sed -i '/->login()$/c\
            ->login()\
            ->brandName(config('\''app.name'\''))' ./app/Providers/Filament/AdminPanelProvider.php

    awk '
/'\''primary'\'' => Color::Amber,/ {
    print "                // '\''primary'\'' => Color::Amber,"
    print "                '\''primary'\'' => Color::Teal,"
    print "                '\''gray'\'' => Color::Gray,"
    print "                '\''info'\'' => Color::Blue,"
    print "                '\''success'\'' => Color::Emerald,"
    print "                '\''warning'\'' => Color::Orange,"
    print "                '\''danger'\'' => Color::Rose,"
    next
}
1
' ./app/Providers/Filament/AdminPanelProvider.php > tmpfile && mv tmpfile ./app/Providers/Filament/AdminPanelProvider.php
    
    awk '
{
    if ($0 ~ /->discoverResources\(/) {
        print "            ->darkMode(false)"
        print "            ->viteTheme('\''resources/css/filament/admin/theme.css'\'')"
        print "            ->font('\''Ubuntu'\'')"
        print "            ->navigationGroups([])"
    }
    print $0
}
' ./app/Providers/Filament/AdminPanelProvider.php > tmpfile && mv tmpfile ./app/Providers/Filament/AdminPanelProvider.php

    sed -i '/Widgets\\FilamentInfoWidget::class,/a\                OverlookWidget::class,' ./app/Providers/Filament/AdminPanelProvider.php

    if [ "$is_localized" == true ]; then
        awk '
{
    if ($0 ~ /]\);/) {
        print "            ])"
        print "            ->plugins(["
        print "                FilamentShieldPlugin::make(),"
        print "                OverlookPlugin::make()"
        print "                    ->sort(2)"
        print "                    ->columns(["
        print "                        '\''default'\'' => 1,"
        print "                        '\''sm'\'' => 2,"
        print "                        '\''md'\'' => 3,"
        print "                        '\''lg'\'' => 4,"
        print "                        '\''xl'\'' => 5,"
        print "                        '\''2xl'\'' => null,"
        print "                    ]),"
        print "                SpatieLaravelTranslatablePlugin::make()"
        print "                    ->defaultLocales(available_locales()),"
        print "                TranslationManagerPlugin::make(),"
        print "            ]);"
        next
    }
    print $0
}
' ./app/Providers/Filament/AdminPanelProvider.php > tmpfile && mv tmpfile ./app/Providers/Filament/AdminPanelProvider.php
    else
        awk '
{
    if ($0 ~ /]\);/) {
        print "            ])"
        print "            ->plugins(["
        print "                FilamentShieldPlugin::make(),"
        print "                OverlookPlugin::make()"
        print "                    ->sort(2)"
        print "                    ->columns(["
        print "                        '\''default'\'' => 1,"
        print "                        '\''sm'\'' => 2,"
        print "                        '\''md'\'' => 3,"
        print "                        '\''lg'\'' => 4,"
        print "                        '\''xl'\'' => 5,"
        print "                        '\''2xl'\'' => null,"
        print "                    ]),"
        print "            ]);"
        next
    }
    print $0
}
' ./app/Providers/Filament/AdminPanelProvider.php > tmpfile && mv tmpfile ./app/Providers/Filament/AdminPanelProvider.php
    fi

    php artisan filament:assets $conditional_quiet
    php artisan optimize:clear $conditional_quiet
fi

sed -i "s/REDIS_HOST=127.0.0.1/REDIS_CLIENT=predis\nREDIS_HOST=127.0.0.1/g" ./.env

echo -e "\nConfigured [app] config file for providers and facades." >&3

if [ -n "$EXPOSE_TOKEN" ]; then
    # Modify the TrustProxies middleware to work with Expose
    sed -i "s/protected \$proxies;/protected \$proxies = '*';/g" ./app/Http/Middleware/TrustProxies.php

    echo -e "\nTrusted all proxies for Expose compatibility." >&3
fi

if [ "$is_localized" == true ]; then
    # Publish lang folder
    php artisan lang:publish $conditional_quiet

    echo -e "\nPublished the [lang] folder." >&3

    # Laravel Localization package
    php artisan vendor:publish --provider="Mcamara\LaravelLocalization\LaravelLocalizationServiceProvider" $conditional_quiet

    sed -i "/'verified' => \\\\Illuminate\\\\Auth\\\\Middleware\\\\EnsureEmailIsVerified::class,/a \
\xxxxxx\n        // * =========\
\n        // * Packages\
\n        // * =======\
\n\
\n        'localize' => \\\\Mcamara\\\\LaravelLocalization\\\\Middleware\\\\LaravelLocalizationRoutes::class,\
\n        'localizationRedirect' => \\\\Mcamara\\\\LaravelLocalization\\\\Middleware\\\\LaravelLocalizationRedirectFilter::class,\
\n        'localeSessionRedirect' => \\\\Mcamara\\\\LaravelLocalization\\\\Middleware\\\\LocaleSessionRedirect::class,\
\n        'localeCookieRedirect' => \\\\Mcamara\\\\LaravelLocalization\\\\Middleware\\\\LocaleCookieRedirect::class,\
\n        'localeViewPath' => \\\\Mcamara\\\\LaravelLocalization\\\\Middleware\\\\LaravelLocalizationViewPath::class," ./app/Http/Kernel.php
    sed -i 's/xxxxxx//g' ./app/Http/Kernel.php

    sed -i "s/^\(        \)'es'/\1\/\/ 'es'/" ./config/laravellocalization.php
    sed -i "s/^\(        \)\/\/'ar'/\1'ar'/" ./config/laravellocalization.php

    php artisan lang:add ar $conditional_quiet

    echo -e "\nConfigured Laravel Localization and enabled AR & EN locales." >&3
fi

# Laravel Telescope package
php artisan telescope:install $conditional_quiet
echo -e "\nTELESCOPE_ENABLED=true" | tee -a ./.env

awk '
BEGIN { RS = ""; ORS = "\n\n" } 
/public function register\(\): void\n    {\n        \/\/\n    }/ {
  gsub(/public function register\(\): void\n    {\n        \/\/\n    }/, 
       "public function register(): void\n    {\n        if ($this->app->environment('\''local'\'')) " \
       "{\n            $this->app->register(\\Laravel\\Telescope\\TelescopeServiceProvider::class);\n" \
       "            $this->app->register(TelescopeServiceProvider::class);\n        }\n    }");
} 
{ print }
' ./app/Providers/AppServiceProvider.php > temp.txt && mv temp.txt ./app/Providers/AppServiceProvider.php
sed -i "s~\"dont-discover\": \[\]~\"dont-discover\": \[\n                \"laravel/telescope\"\n            \]~g" ./composer.json

php artisan vendor:publish --tag=telescope-migrations $conditional_quiet
php artisan migrate $conditional_quiet

echo -e "\nConfigured Laravel Telescope." >&3

# Laravel Scout package
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider" $conditional_quiet
echo -e "\nSCOUT_DRIVER=database" | tee -a ./.env

echo -e "\nConfigured Laravel Scout." >&3

# Laravel Media Library package
php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="migrations" $conditional_quiet
php artisan migrate $conditional_quiet

php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="config" $conditional_quiet
sed -i "s~'CacheControl' => 'max-age=604800',~'CacheControl' => 'max-age=604800',\n            'visibility' => 'public',~g" ./config/media-library.php
echo -e "\nMEDIA_DISK=s3" | tee -a ./.env

echo -e "\nConfigured Laravel Media Library to work with MinIO." >&3

# Eloquent Sortable package
php artisan vendor:publish --tag=eloquent-sortable-config $conditional_quiet
sed -i "s/'order_column',/'sorting_order',/g" ./config/eloquent-sortable.php

echo -e "\nInstalled Eloquent Sortable and set 'sorting_order' as the default column." >&3

# Laravel Tags package
php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-migrations" $conditional_quiet
php artisan migrate $conditional_quiet

php artisan vendor:publish --provider="Spatie\Tags\TagsServiceProvider" --tag="tags-config" $conditional_quiet

echo -e "\nConfigured Laravel Tags." >&3

# Laravel Permission package
sed -i 's|use Laravel\\Sanctum\\HasApiTokens;|use Laravel\\Sanctum\\HasApiTokens;\nuse Spatie\\Permission\\Traits\\HasRoles;|' ./app/Models/User.php
sed -i 's/^\(\s*\)use HasApiTokens, HasFactory, Notifiable;$/\1use HasApiTokens, HasFactory, Notifiable;\n\1use HasRoles;/' ./app/Models/User.php

php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" $conditional_quiet

echo -e "\nConfigured Laravel Permission." >&3

# Laravel Settings package
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="migrations" $conditional_quiet
php artisan migrate $conditional_quiet

# TODO change tag to 'config' when PR is approved
php artisan vendor:publish --provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider" --tag="settings" $conditional_quiet

echo -e "\nConfigured Laravel Settings." >&3

# Laravel-Wave package
php artisan vendor:publish --tag="wave-config" $conditional_quiet
sed -i "s/BROADCAST_DRIVER=log/BROADCAST_DRIVER=redis/g" ./.env

rm ./resources/js/bootstrap.js

mkdir ./resources/js/core
sudo cp $lara_stacker_dir/files/resources/js/core/echo.js ./resources/js/core/

echo -e "\nConfigured Laravel-Wave as Laravel Echo implementation." >&3

# Set up Breeze routes in place
php artisan make:controller HomeController $conditional_quiet

if [ "$laravel_stack" != "tall" ]; then
    awk '
BEGIN { RS = ""; ORS = "\n\n" } 
/class HomeController extends Controller\n{\n    \/\/\n}/ {
  gsub(/class HomeController extends Controller\n{\n    \/\/\n}/, "class HomeController extends Controller\n{\n    public function home()\n    {\n        return view('\''home'\'');\n    }\n\n    public function dashboard()\n    {\n        return view('\''dashboard'\'');\n    }\n}");
} 
{ print }
' ./app/Http/Controllers/HomeController.php > temp.txt && mv temp.txt ./app/Http/Controllers/HomeController.php

    sed -i 's|use Illuminate\\Support\\Facades\\Route;|use App\\Http\\Controllers\\HomeController;\nuse App\\Http\\Controllers\\ProfileController;\nuse Illuminate\\Support\\Facades\\Route;|' ./routes/web.php
    awk 'BEGIN { RS = ""; ORS = "\n\n" }
/Route::get\(\47\/\47, function \(\) {\n    return view\(\47welcome\47\);\n}\);/ {
  gsub(/Route::get\(\47\/\47, function \(\) {\n    return view\(\47welcome\47\);\n}\);/,
"Route::get(\47/\47, [HomeController::class, \47home\47])->name(\47home\47);\n\nRoute::get(\47/dashboard\47, [HomeController::class, \47dashboard\47])\n    ->middleware([\47auth\47, \47verified\47])\n    ->name(\47dashboard\47);\n\nRoute::middleware(\47auth\47)->group(function () {\n    Route::get(\47/profile\47, [ProfileController::class, \47edit\47])->name(\47profile.edit\47);\n    Route::patch(\47/profile\47, [ProfileController::class, \47update\47])->name(\47profile.update\47);\n    Route::delete(\47/profile\47, [ProfileController::class, \47destroy\47])->name(\47profile.destroy\47);\n});\n\nrequire __DIR__.\47/auth.php\47;");
}
{ print }' ./routes/web.php > temp.txt && mv temp.txt ./routes/web.php
fi

mv ./resources/views/welcome.blade.php ./resources/views/home.blade.php

echo -e "\nSet up Breeze routes in place." >&3

if [ "$OPINIONATED" == true ]; then
    # Prevent lazy-loading on all models
    sed -i 's|use Illuminate\\Support\\ServiceProvider;|use Illuminate\\Database\\Eloquent\\Model;\nuse Illuminate\\Support\\ServiceProvider;|' ./app/Providers/AppServiceProvider.php
    awk '
BEGIN { RS = ""; ORS = "\n\n" } 
/public function boot\(\): void\n    {\n        \/\/\n    }/ {
  gsub(/public function boot\(\): void\n    {\n        \/\/\n    }/, "public function boot(): void\n    {\n        Model::preventLazyLoading(!app()->isProduction());\n    }");
} 
{ print }
' ./app/Providers/AppServiceProvider.php > temp.txt && mv temp.txt ./app/Providers/AppServiceProvider.php

    echo -e "\nPrevented lazy-loading on all models by default." >&3
fi

# * =============
# * Stacks Setup
# * ===========

if [ "$laravel_stack" = "tall" ]; then
    # Alpine.js framework
    sudo cp -r $lara_stacker_dir/files/_stubs/tall/resources/js/packages ./resources/js/
    sudo cp -r $lara_stacker_dir/files/_stubs/tall/resources/js/data ./resources/js/
    sudo cp -r $lara_stacker_dir/files/_stubs/tall/resources/js/bindings ./resources/js/
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/js/core/alpine-livewire.js ./resources/js/core/
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/js/app.js ./resources/js/

    echo -e "\nConfigured Livewire and AlpineJS frameworks." >&3

    # Livewire framework
    php artisan livewire:publish --config $conditional_quiet

    awk '
BEGIN { RS = ""; ORS = "\n\n" } 
/class HomeController extends Controller\n{\n    \/\/\n}/ {
  gsub(/class HomeController extends Controller\n{\n    \/\/\n}/, "class HomeController extends Controller\n{\n    public function home()\n    {\n        return view('\''home'\'');\n    }\n}");
} 
{ print }
' ./app/Http/Controllers/HomeController.php > temp.txt && mv temp.txt ./app/Http/Controllers/HomeController.php

    php artisan make:controller --invokable LoginRedirect
    sed -i 's|//|return redirect()->back();|' ./app/Http/Controllers/LoginRedirect.php

    if [ "$is_localized" == true ]; then
        sed -i 's|use Illuminate\\Support\\Facades\\Route;|use App\\Http\\Controllers\\HomeController;\nuse App\\Http\\Controllers\\LoginRedirect;\nuse Illuminate\\Support\\Facades\\Route;\nuse Mcamara\\LaravelLocalization\\Facades\\LaravelLocalization;|' ./routes/web.php
        awk '
/Route::get\('\''\/'\'', function \(\) {/ && !done {
    print "Route::get('\''/'\'', [HomeController::class, '\''home'\''])->name('\''home'\'');";
    print "";
    print "Route::middleware(['\''guest'\''])->group(function () {";
    print "    Route::get('\''/login'\'', LoginRedirect::class)->name('\''login'\'');";
    print "});";
    print "";
    print "// ? Prefix routes with locales";
    print "Route::group([";
    print "    '\''prefix'\'' => LaravelLocalization::setLocale(),";
    print "    '\''middleware'\'' => [";
    print "        '\''localeSessionRedirect'\'',";
    print "    ],";
    print "], function () {";
    print "    // ? Localizing livewire requests";
    print "    Livewire::setUpdateRoute(function ($handle) {";
    print "        return Route::post('\''/livewire/update'\'', $handle)->name('\''livewire.update'\'');";
    print "    });";
    print "";
    print "    // ? Translate routes";
    print "    Route::middleware('\''localize'\'')->group(function () {";
    print "        // ? Only for guests";
    print "        Route::group(['\''middleware'\'' => '\''guest'\''], function () {";
    print "            // // * Login";
    print "            // Route::get(LaravelLocalization::transRoute('\''routes.login'\''), Login::class)->name('\''login'\'');";
    print "        });";
    print "";
    print "        // ? Only for users";
    print "        Route::group(['\''middleware'\'' => '\''auth'\''], function () {";
    print "            // // * Logout";
    print "            // Route::get(LaravelLocalization::transRoute('\''routes.logout'\''), Logout::class)->name('\''logout'\'');";
    print "        });";
    print "";
    print "        // // * Home";
    print "        // Route::view('\''/'\'', '\''home'\'');";
    print "    });";
    print "});";
    done=1;
    next;
}
!done { print }
' ./routes/web.php > temp.txt && mv temp.txt ./routes/web.php
    else
        sed -i 's/use Illuminate\\Support\\Facades\\Route;/use App\\Http\\Controllers\\HomeController;\
use App\\Http\\Controllers\\LoginRedirect;\
&/' ./routes/web.php
        awk '
/Route::get\('\''\/'\'', function \(\) {/ && !done {
    print "Route::get('\''/'\'', [HomeController::class, '\''home'\''])->name('\''home'\'');";
    print "";
    print "Route::middleware(['\''guest'\''])->group(function () {";
    print "    Route::get('\''/login'\'', LoginRedirect::class)->name('\''login'\'');";
    print "});";
    done=1;
    next;
}
!done { print }
' ./routes/web.php > temp.txt && mv temp.txt ./routes/web.php
    fi

    sed -i "/App\\Http\\Controllers\\ProfileController;/d" ./routes/web.php

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

    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/home.blade.php ./resources/views/
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/components/home/link.blade.php ./resources/views/components/home/

    if [ "$OPINIONATED" == true ]; then
        if [ "$is_localized" == true ]; then
            sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/partials/localized-opinionated-fader.blade.php ./resources/views/partials/fader.blade.php
        else
            sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/partials/opinionated-fader.blade.php ./resources/views/partials/fader.blade.php
        fi
    else
        sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/partials/fader.blade.php ./resources/views/partials/
    fi

    if [[ "$OPINIONATED" == true && "$is_localized" == true ]]; then
        sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/components/localized-app.blade.php ./resources/views/components/app.blade.php
    else
        sudo cp $lara_stacker_dir/files/_stubs/tall/resources/views/components/app.blade.php ./resources/views/components/
    fi

    sed -i "s/'layout' => 'components.layouts.app',/'layout' => 'components.app',/g" ./config/livewire.php
    sed -i "s/'disk' => null,/'disk' => 's3',/g" ./config/livewire.php

    echo -e "\nConfigured Livewire framework." >&3

    # Alpine Animate package
    echo -e "\nConfigured Alpine Animate plugin. (Reverse capability in [home.blade.php])" >&3

    # Alpine.js Breakpoints package
    echo -e "\nConfigured AlpineJS Breakpoints plugin. (Listeners in [app.blade.php])" >&3

    # Livewire Hot-Reload package
    sudo cp $lara_stacker_dir/files/_stubs/tall/vite.config.js ./
    sudo cp $lara_stacker_dir/files/_stubs/tall/resources/js/core/livewire-hot-reload.js ./resources/js/core/
    echo -e "\nVITE_LIVEWIRE_OPT_IN=true" | tee -a ./.env

    sed -i "s~<projectName>~$escaped_project_name~g" ./vite.config.js

    echo -e "\nConfigured Livewire Hot-Reload watcher." >&3

    # Blurred Image package
    php artisan blurred-image:install $conditional_quiet

    echo -e "\nConfigured Blurred Image and Blurhash." >&3

    # Filament Shield package
    sed -i 's|use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;|use Filament\\Models\\Contracts\\FilamentUser;\
use Filament\\Panel;\
&|' ./app/Models/User.php
    sed -i 's|extends Authenticatable|& implements FilamentUser|' ./app/Models/User.php
    awk '
{
    buffer[NR] = $0
}
END {
    for(i = 1; i <= NR; i++) {
        if(i == NR) {
            print ""
            print "    public function canAccessPanel(Panel $panel): bool"
            print "    {"
            print "        return str(env('"'"'ENV_USER_EMAIL'"'"'))->lower()->value() === str($this->email)->lower()->value();"
            print "    }"
        }
        print buffer[i]
    }
}' ./app/Models/User.php > tmp_file && mv tmp_file ./app/Models/User.php

    php artisan vendor:publish --tag=filament-shield-config $conditional_quiet
    sed -i "s~'navigation_group' => true,~'navigation_group' => false,~g" ./config/filament-shield.php

    if $cancel_suppression; then
        echo -e "yes\nno" | php artisan shield:install --fresh --only $conditional_quiet 2>&1
    else
        echo -e "yes\nno" | php artisan shield:install --fresh --only $conditional_quiet 2>&1 >/dev/null
    fi

    echo -e "\nConfigured Filament Shield for role management page." >&3

    # Filament Admin package
    php artisan vendor:publish --tag=filament-config $conditional_quiet
    php artisan make:filament-theme $conditional_quiet

    sed -i "s|'./vendor/filament/\*\*/\*.blade.php',|'./vendor/filament/\*\*/\*.blade.php',\n        './vendor/awcodes/overlook/resources/\*\*/\*.blade.php',|g" ./resources/css/filament/admin/tailwind.config.js

    sed -i '/"@php artisan package:discover --ansi"/c\            "@php artisan package:discover --ansi",\n            "@php artisan filament:upgrade"' ./composer.json

    echo -e "\nConfigured Filament admin panel." >&3

    # Overlook package
    echo -e "\nConfigured Filament Overlook plugin." >&3

    if [ "$is_localized" == true ]; then
        # Filament translation manager
        sed -i '/use Illuminate\\Database\\Eloquent\\Model;/c \
use App\\Models\\User;\
use Illuminate\\Database\\Eloquent\\Model;\
use Illuminate\\Support\\Facades\\Gate;' ./app/Providers/AppServiceProvider.php
        sed -i '/Model::preventLazyLoading(!app()->isProduction());/c\
        Model::preventLazyLoading(!app()->isProduction());\
\
        // * =========\
        // * Packages\
        // * =======\
\
        Gate::define('"'"'use-translation-manager'"'"', function (?User $user) {\
            return str(env('"'"'ENV_USER_EMAIL'"'"'))->lower()->value() === str($user->email)->lower()->value();\
        });' ./app/Providers/AppServiceProvider.php

        php artisan vendor:publish --tag=translation-manager-config $conditional_quiet
        awk '{
    if ($0 ~ /\[.code. => .en., .name. => .English., .flag. => .gb.\],/) {
        print "        [\"code\" => \"ar\", \"name\" => \"العربية\", \"flag\" => \"sa\"],"
        print "        [\"code\" => \"en\", \"name\" => \"English\", \"flag\" => \"gb\"],"
        getline
    } else {
        print $0
    }
}' ./config/translation-manager.php > tmp.txt && mv tmp.txt ./config/translation-manager.php

        sed -i "s/'show_flags' => false,/'show_flags' => true,/g" ./config/translation-manager.php
        sed -i "s/'quick_translate_navigation_registration' => false,/'quick_translate_navigation_registration' => true,/g" ./config/translation-manager.php

        php artisan vendor:publish --provider="Spatie\TranslationLoader\TranslationServiceProvider" --tag="migrations" $conditional_quiet
        cd ./database/migrations/
        last_file=$(ls -A1 | tail -n 1)
        sudo sed -i '/$table->bigIncrements('"'"'id'"'"');/,/$table->timestamps();/c\
            $table->bigIncrements('"'"'id'"'"');\
            $table->string('"'"'group'"'"')->index();\
            $table->string('"'"'key'"'"')->index();\
            $table->json('"'"'text'"'"');\
            $table->timestamps();' ./$last_file
        cd $PROJECTS_DIRECTORY/$escaped_project_name/

        php artisan migrate $conditional_quiet

        echo -e "\nConfigured Filament Translation Manager plugin." >&3
    fi
fi

# TODO other stacks...

# * ==========================
# * Opinionated Modifications
# * ========================

cd $PROJECTS_DIRECTORY/$escaped_project_name

if [ "$OPINIONATED" == true ]; then
    if [ "$is_localized" == true ]; then
        # Move lang folder to resources folder
        mv ./lang ./resources/

        echo -e "\nMoved lang folder to [resources] folder." >&3
    fi

    # Add a project-specific config file
    cp $lara_stacker_dir/files/config/project-name.php ./config/$escaped_project_name.php

    echo -e "\nCreated a [config/$escaped_project_name.php] file." >&3

    # Add an environment variable for password timeout
    sed -i "s/'password_timeout' => 10800,/'password_timeout' => config('PASSWORD_TIMEOUT', 10800),/g" ./config/auth.php
    sed -i "s/SESSION_LIFETIME=120/SESSION_LIFETIME=120\nPASSWORD_TIMEOUT=10800/g" ./.env

    echo -e "\nAdded an environment variable for password timeout." >&3

    # Extract an Enumerifier helper trait
    mkdir ./app/Enums
    mkdir -p ./app/Services/Support/Traits

    sudo cp $lara_stacker_dir/files/app/Services/Support/Traits/Enumerifier.php ./app/Services/Support/Traits/
    sudo cp $lara_stacker_dir/files/app/Enums/Example.php ./app/Enums/

    echo -e "\nExtracted an Example enum with an Enumerifier helper trait." >&3

    # Add an environment-user seeder
    awk '
{
    if ($0 ~ /\/\/ \\App\\Models\\User::factory\(10\)->create\(\);/) {
        print "        \\App\\Models\\User::factory()->create([";
        print "            '\''name'\'' => env('\''ENV_USER_NAME'\''),";
        print "            '\''email'\'' => env('\''ENV_USER_EMAIL'\''),";
        print "            '\''password'\'' => env('\''ENV_USER_PASSWORD'\''),";
        print "        ]);";
        for (i=0; i<5; i++) getline;
    } else {
        print $0;
    }
}' ./database/seeders/DatabaseSeeder.php > tmp.txt && mv tmp.txt ./database/seeders/DatabaseSeeder.php
    echo -e "\nENV_USER_NAME=Admin" | tee -a ./.env
    echo -e "ENV_USER_EMAIL=admin@laravel.com" | tee -a ./.env
    echo -e "ENV_USER_PASSWORD=password" | tee -a ./.env

    php artisan db:seed $conditional_quiet

    echo -e "\nSeeded an environment-user for quick generation." >&3

    # Prettier config
    sudo cp $lara_stacker_dir/files/.opinionated/.prettierrc ./.prettierrc

    echo -e "\nCopied Prettier configuration file." >&3

    # Updated .gitignore file
    sudo cp $lara_stacker_dir/files/.gitignore ./

    echo -e "\nUpdated .gitignore file." >&3

    if [[ $USING_VSC == true && $OPINIONATED == true ]]; then
        # Copy the opinionated VSC keybindings
        sudo cp $lara_stacker_dir/files/.opinionated/keybindings.json ./.vscode/

        if [ $use_pest == false ]; then
            sudo sed -i 's/better-pest/better-phpunit/g' ./.vscode/keybindings.json
        fi

        echo -e "\nCopied VSC workspace key-bindings." >&3

        # Create a dedicated VSC workspace in Desktop
        cd /home/$USERNAME/Desktop

        sudo cp $lara_stacker_dir/files/.opinionated/project.code-workspace ./$escaped_project_name.code-workspace

        sudo sed -i "s/<projectName>/$escaped_project_name/g" ./$escaped_project_name.code-workspace
        sudo sed -i "s~<projectsDirectory>~$PROJECTS_DIRECTORY~g" ./$escaped_project_name.code-workspace

        sudo $lara_stacker_dir/scripts/helpers/permit.sh ./$escaped_project_name.code-workspace

        echo -e "\nCreated a dedicated VSC workspace in Desktop." >&3
    fi
fi

# * ========
# * The End
# * ======

cd $PROJECTS_DIRECTORY/$escaped_project_name

# Update the permissions all around
sudo $lara_stacker_dir/scripts/helpers/permit.sh $PROJECTS_DIRECTORY/$escaped_project_name

echo -e "\nUpdated directory and file permissions all around." >&3

# Build the front-end assets
composer update -n $conditional_quiet
npm update
npm run build

echo -e "\nFront-end assets compiled successfully and everything is up-to-date." >&3

# Display a success message
echo -e "\nProject created successfully! You can access it at: [https://$escaped_project_name.test].\n" >&3

echo -n "Press any key to continue..." >&3
read whatever

clear >&3
