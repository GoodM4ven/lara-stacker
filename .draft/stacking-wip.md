key_desc["laravel"]="Install Laravel via Composer"
key_desc["ssl"]="Generate SSL certificate with mkcert"
key_desc["apache"]="Configure Apache for a dynamic server"
key_desc["mysql"]="Create a MySQL database"
key_desc["vsc-xdebug"]="Configure VSC Xdebug settings"

key_desc["gitignore"]="Update .gitignore file"
key_desc["vsc-settings"]="Configure VSC Xdebug settings"
key_desc["vsc-keybindings"]="Configure VSC Xdebug settings"

Configured VSC debug settings for Xdebug support.
Configured and copied VSC extension settings and key-bindings.
Published the [lang] folder to [resources] folder.
Added an environment variable for password timeout.
Installed Redis, predis and the Redis facade in the project.
Set up a MinIO storage for the project.
CodeSniffer (phpcs) installed.
Installed Laravel Localization package and enabled (AR and EN).
Created a helper functions file and registered it in [composer.json].
Installed and configured Laravel Pest for testing.
Enabled all proxies for Expose compatibility.
Installed TailwindCSS.
Installed ALpine.js.
Installed Laravel-Wave for Laravel Echo implementation.
Installed Livewire.
Installed Livewire Hot-Reload package.
Installed Laravel Telescope for request debugging.
Installed Laravel Scout for search optimization.
Added an environment-user for quick generation.
Set the RouteServiceProvider home's to '/'.
Updated directory and file permissions all around.
Project created successfully! You can access it at: [https://alisabsabi.test].
Note: File permissions through VSC need about a minute or two to kick in; after indexing via PHP Intelephense extension.

```bash
# define an associative array to store keys, descriptions, and statuses
declare -A key_desc=()
key_desc["key1"]="description1"
key_desc["key2"]="description2"
key_desc["key3"]="description3"
declare -A key_status=()
key_status["key1"]="default"
key_status["key2"]="disabled"
key_status["key3"]="enabled"

# function to display table for keys, descriptions, and statuses
function display_table {
    # sort keys based on status (enabled keys first, then disabled keys)
    default_keys=()
    enabled_keys=()
    disabled_keys=()
    for key in "${!key_status[@]}"; do
        if [[ ${key_status[$key]} == "default" ]]; then
            default_keys+=("$key")
        elif [[ ${key_status[$key]} == "enabled" ]]; then
            enabled_keys+=("$key")
        else
            disabled_keys+=("$key")
        fi
    done
    sorted_keys=("${default_keys[@]}" "${enabled_keys[@]}" "${disabled_keys[@]}")

    # display table with sorted keys
    echo ""
    printf "%-15s %-40s %s\n" "Key" "Description" "Status"
    echo ""
    for key in "${sorted_keys[@]}"; do
        if [[ ${key_status[$key]} == "default" ]]; then
            status="☑️"
        elif [[ ${key_status[$key]} == "enabled" ]]; then
            status="✅"
        else
            status="❌"
        fi
        printf "%-15s %-40s %s\n" "$key" "${key_desc[$key]}" "$status"
    done
}

# display table for initial keys, descriptions, and statuses
display_table

# loop to continuously prompt user for keys and toggle their statuses
while true; do
    echo ""
    read -p "Enter key (or 'stack' to finish): " key
    if [[ "$key" == "stack" ]]; then
        break  # exit loop when user is done entering keys
    fi
    if [[ ${key_desc[$key]} ]]; then
        if [[ ${key_status[$key]} == "enabled" ]]; then
            key_status[$key]="disabled"
        elif [[ ${key_status[$key]} == "disabled" ]]; then
            key_status[$key]="enabled"
        else
            echo -e "\nKey is enforced by default. It cannot be disabled."
        fi
        display_table
    else
        echo -e "\nInvalid key. Please enter a valid key or 'done' to finish."
        display_table
    fi
done

# ! USAGE
if [[ ${key_status[$key]} == "enabled" ]]; then
    # perform logic for enabled key here
    echo "$key is enabled"
fi
```