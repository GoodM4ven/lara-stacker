#!/bin/bash

clear

# ? Display a status indicator
changelog_dir="./CHANGELOG.md"
current_version="???"
if [[ -f $changelog_dir ]]; then
    current_version=$(grep -E "^## v[0-9]+" $changelog_dir | head -1 | awk '{print $2}')
fi
echo -e "-=|[ LARA-STACKER [$current_version] ]|=-\n"

# * ===========
# * Validation
# * =========

# ? Check if prompt script exists before sourcing
prompt_function_dir="./scripts/functions/prompt.sh"
if [[ ! -f $prompt_function_dir ]]; then
    echo -e "Error: Working directory isn't the script's main.\n"

    echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

    echo -n "Press any key to exit..."
    read whatever

    clear
    exit 1
fi
source $prompt_function_dir

# ? Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    prompt "Aborted for missing super-user (sudo) permission." "Run the script using [sudo ./lara-stacker.sh] command."
fi

# ? Ensure that .env file exists
if [ ! -f "./.env" ]; then
    prompt "Aborted for missing [.env] file." "Copy one using [cp .env.example .env] command then fill its values."
fi

# ? Double check the environment variables
env_example_vars=$(grep -oE '^[A-Z_]+=' .env.example | sort)
env_vars=$(grep -oE '^[A-Z_]+=' .env | sort)
diff <(echo "$env_example_vars") <(echo "$env_vars") &>/dev/null
if [ $? -ne 0 ]; then
    prompt "Aborted for different environment variables." "Ensure that [.env.example] variables match [.env] ones."
fi

# ? Ensure all side scripts are executable
SCRIPTS=(
    "./scripts/update.sh"
    "./scripts/setup.sh"
    "./scripts/create_raw.sh"
    "./scripts/TALL/list.sh"
    "./scripts/TALL/create.sh"
    "./scripts/TALL/import.sh"
    "./scripts/TALL/delete.sh"
    "./scripts/mysql/list.sh"
    "./scripts/mysql/create.sh"
    "./scripts/mysql/delete.sh"
    "./scripts/apache/list.sh"
    "./scripts/apache/enable.sh"
    "./scripts/apache/disable.sh"
    "./scripts/helpers/permit.sh"
)
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ ! -x "$script" ]]; then
            chmod +x "$script"
        fi
    else
        prompt "Aborted for missing [$script] file." "Clone the latest [GoodM4ven/lara-stacker] github repository."
    fi
done

# * ============
# * Preparation
# * ==========

# ? Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# * ========
# * Process
# * ======

# ? Checking for updates
if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
    rm /tmp/updated-lara-stacker.flag
fi

echo -en "Checking for updates"
sleep 1
echo -en "."
sleep 1
echo -en "."

update_available=false
latest_version=$(wget -qO- "https://api.github.com/repos/GoodM4ven/lara-stacker/releases/latest" | jq -r .tag_name)
if [[ "$current_version" != "$latest_version" ]]; then
    update_available=true
fi

echo -en "."

clear

# ? Display the update version, if any
if [ "$update_available" == true ]; then
    echo -e "New version ($latest_version) is available!\n"
fi

# ? Loop the menu until user chooses to exit
counter=0
while true; do
    counter=$((counter + 1))

    echo -e "-=|[ LARA-STACKER [$current_version] ]|=-\n"

    echo -e "Available Operations:\n"

    options=("1. Manage TALL Projects" "2. Manage MySQL Databases" "3. Manage Apache Sites" "4. Create A Raw Laravel Project" "5. Exit")

    # ? Conditional options
    include_zero=false
    if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
        rm /tmp/updated-lara-stacker.flag
        update_available=false
    fi
    if [ "$update_available" == true ]; then
        options+=("6. Download Updates")
    fi
    if [[ ! -f "$lara_stacker_dir/done-setup.flag" ]]; then
        options+=("0. Initial Setup")
        include_zero=true
    fi

    for opt in "${options[@]}"; do
        echo "$opt "
    done

    echo ""
    if [[ $counter -eq 1 && "$1" ]]; then
        choice="$1"
    else
        if [ "$include_zero" == true ]; then
            options_count=$((${#options[@]} - 1))
            read -p "Choose an operation (0-$options_count): " choice
        else
            options_count=$((${#options[@]}))
            read -p "Choose an operation (1-$options_count): " choice
        fi
    fi

    clear

    # ? Options logic
    case $choice in
    0)
        if [[ -f "$lara_stacker_dir/done-setup.flag" ]]; then
            prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/setup.sh
        fi
        ;;
    1)
        while true; do
            clear

            echo -e "-=|[ Lara-Stacker |> TALL PROJECTS MANAGEMENT ]|=-\n"

            echo -e "TALL Stack Frameworks:\n"

            echo "- TailwindCSS"
            echo "- AlpineJS"
            echo "- Livewire"
            echo -e "- Laravel\n"

            echo -e "Available Operations:\n"

            echo "1. List All Projects"
            echo "2. Create A Project"
            echo "3. Delete A Project"
            echo "4. Import A Project"
            echo -e "5. Go Back To Main Menu\n"

            read -p "Choose an operation (1-5): " stack_choice

            case $stack_choice in
            1)
                RAN_MAIN_SCRIPT="true" ./scripts/TALL/list.sh
                ;;
            2)
                sudo RAN_MAIN_SCRIPT="true" ./scripts/TALL/create.sh
                ;;
            3)
                sudo RAN_MAIN_SCRIPT="true" ./scripts/TALL/delete.sh
                ;;
            4)
                sudo RAN_MAIN_SCRIPT="true" ./scripts/TALL/import.sh
                ;;
            5)
                clear
                break
                ;;
            *)
                clear
                prompt "-=|[ Lara-Stacker |> TALL PROJECTS MANAGEMENT ]|=-" "Invalid option! Please type one the of digits in the list..." false true
                ;;
            esac
        done
        ;;
    2)
        while true; do
            clear

            echo -e "-=|[ Lara-Stacker |> MYSQL DATABASE MANAGEMENT ]|=-\n"

            echo -e "Available Operations:\n"

            echo "1. List All Databases"
            echo "2. Create A Database"
            echo "3. Delete A Database"
            echo -e "4. Go Back To Main Menu\n"

            read -p "Choose an operation (1-4): " db_choice

            case $db_choice in
            1)
                RAN_MAIN_SCRIPT="true" ./scripts/mysql/list.sh
                ;;
            2)
                RAN_MAIN_SCRIPT="true" ./scripts/mysql/create.sh
                ;;
            3)
                RAN_MAIN_SCRIPT="true" ./scripts/mysql/delete.sh
                ;;
            4)
                clear
                break
                ;;
            *)
                clear
                prompt "-=|[ Lara-Stacker |> MYSQL DATABASE MANAGEMENT ]|=-" "Invalid option! Please type one the of digits in the list..." false true
                ;;
            esac
        done
        ;;
    3)
        while true; do
            clear

            echo -e "-=|[ Lara-Stacker |> APACHE SITE MANAGEMENT ]|=-\n"

            echo -e "Available Operations:\n"

            echo "1. List All Sites"
            echo "2. Enable A Site"
            echo "3. Disable A Site"
            echo -e "4. Go Back To Main Menu\n"

            read -p "Choose an operation (1-4): " site_choice

            case $site_choice in
            1)
                RAN_MAIN_SCRIPT="true" ./scripts/apache/list.sh
                ;;
            2)
                RAN_MAIN_SCRIPT="true" ./scripts/apache/enable.sh
                ;;
            3)
                RAN_MAIN_SCRIPT="true" ./scripts/apache/disable.sh
                ;;
            4)
                clear
                break
                ;;
            *)
                clear
                prompt "-=|[ Lara-Stacker |> APACHE SITE MANAGEMENT ]|=-" "Invalid option! Please type one the of digits in the list..." false true
                ;;
            esac
        done
        ;;
    4)
        sudo RAN_MAIN_SCRIPT="true" ./scripts/create_raw.sh
        ;;
    5)
        echo -e "\nExiting Lara-Stacker...\n"
        exit 0
        ;;
    6)
        if [ "$update_available" == false ]; then
            prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/update.sh
        fi
        ;;
    *)
        prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false true
        ;;
    esac
done
