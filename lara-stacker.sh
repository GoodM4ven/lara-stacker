#!/bin/bash

clear

# Status indicator
changelog_dir="./CHANGELOG.md"
current_version="???"
if [[ -f $changelog_dir ]]; then
    current_version=$(grep -E "^## v[0-9]+" $changelog_dir | head -1 | awk '{print $2}')
fi
echo -e "-=|[ LARA-STACKER [$current_version] ]|=-\n"

# * ===========
# * Validation
# * =========

# Check if prompt script exists before sourcing
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

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    prompt "Aborted for missing super-user (sudo) permission." "Run the script using [sudo ./lara-stacker.sh] command." true false
fi

# Ensure that .env file exists
if [ ! -f "./.env" ]; then
    prompt "Aborted for missing [.env] file." "Copy one using [cp .env.example .env] command then fill its values." true false
fi

# Double check the environment variables
env_example_vars=$(grep -oE '^[A-Z_]+=' .env.example | sort)
env_vars=$(grep -oE '^[A-Z_]+=' .env | sort)
diff <(echo "$env_example_vars") <(echo "$env_vars") &>/dev/null
if [ $? -ne 0 ]; then
    prompt "Aborted for different environment variables." "Ensure that [.env.example] variables match [.env] ones." true false
fi

# Ensure all side scripts are executable
SCRIPTS=(
    "./scripts/setup.sh"
    "./scripts/list.sh"
    "./scripts/create.sh"
    "./scripts/create_raw.sh"
    "./scripts/delete.sh"
    "./scripts/update.sh"
    "./scripts/databases/list.sh"
    "./scripts/databases/create.sh"
    "./scripts/databases/delete.sh"
    "./scripts/helpers/permit.sh"
)
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ ! -x "$script" ]]; then
            chmod +x "$script"
        fi
    else
        prompt "Aborted for missing [$script] file." "Clone the latest [GoodM4ven/lara-stacker] github repository." true false
    fi
done

# * ============
# * Preparation
# * ==========

# Get environment variables and defaults
lara_stacker_dir=$PWD
source $lara_stacker_dir/.env

# * =====================
# * Checking For Updates
# * ===================

# Checking for updates
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

# * =============
# * Options Menu
# * ===========

# Display the update version, if any
if [ "$update_available" == true ]; then
    echo -e "New version ($latest_version) available to download!\n"
fi

# Loop until user chooses to exit
counter=0
while true; do
    counter=$((counter + 1))

    echo -e "-=|[ LARA-STACKER [$current_version] ]|=-\n"

    echo -e "Supported Stacks:\n"
    echo -e "- TALL (TailwindCSS, AlpineJS, Livewire, Laravel)\n"

    echo -e "Available Operations:\n"

    options=("1. Stacked Laravel Projects" "2. Manage MySQL Databases" "3. Create A Raw Laravel Project" "4. Exit")

    # Conditional options
    include_zero=false
    if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
        rm /tmp/updated-lara-stacker.flag
        update_available=false
    fi
    if [ "$update_available" == true ]; then
        options+=("5. Download Updates")
    fi
    if [[ ! -f "$lara_stacker_dir/done-setup.flag" ]]; then
        options+=("0. Initial Setup")
        include_zero=true
    fi

    options_count=$((${#options[@]} - 1))

    for opt in "${options[@]}"; do
        echo "$opt "
    done

    echo ""
    if [[ $counter -eq 1 && "$1" ]]; then
        choice="$1"
    else
        if [ "$include_zero" == true ]; then
            read -p "Choose an operation (0-$options_count): " choice
        else
            read -p "Choose an operation (1-$options_count): " choice
        fi
    fi

    clear

    case $choice in
    0)
        if [[ -f "$lara_stacker_dir/done-setup.flag" ]]; then
            prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/setup.sh
        fi
        ;;
    1)
        while true; do
            clear

            echo -e "-=|[ Lara-Stacker |> STACKED PROJECTS ]|=-\n"

            echo -e "Available Operations:\n"

            echo "1. List All Projects"
            echo "2. Stack A New Project"
            echo "3. Delete A Project"
            echo -e "4. Go Back To Main Menu\n"

            read -p "Choose an operation (1-3): " stack_choice

            case $stack_choice in
            1)
                RAN_MAIN_SCRIPT="true" ./scripts/list.sh
                ;;
            2)
                sudo RAN_MAIN_SCRIPT="true" ./scripts/create.sh
                ;;
            3)
                sudo RAN_MAIN_SCRIPT="true" ./scripts/delete.sh
                ;;
            4)
                clear
                break
                ;;
            *)
                clear
                prompt "-=|[ Lara-Stacker |> STACKED PROJECTS ]|=-" "Invalid option! Please type one the of digits in the list..." false false true
                ;;
            esac
        done
        ;;
    2)
        while true; do
            clear

            echo -e "-=|[ Lara-Stacker |> DATABASE MANAGEMENT ]|=-\n"

            echo -e "Available Operations:\n"

            echo "1. List All Databases"
            echo "2. Create A Database"
            echo "3. Delete A Database"
            echo -e "4. Go Back To Main Menu\n"

            read -p "Choose an operation (1-3): " db_choice

            case $db_choice in
            1)
                RAN_MAIN_SCRIPT="true" ./scripts/databases/list.sh
                ;;
            2)
                RAN_MAIN_SCRIPT="true" ./scripts/databases/create.sh
                ;;
            3)
                RAN_MAIN_SCRIPT="true" ./scripts/databases/delete.sh
                ;;
            4)
                clear
                break
                ;;
            *)
                clear
                prompt "-=|[ Lara-Stacker |> DATABASE MANAGEMENT ]|=-" "Invalid option! Please type one the of digits in the list..." false false true
                ;;
            esac
        done
        ;;
    3)
        sudo RAN_MAIN_SCRIPT="true" ./scripts/create_raw.sh
        ;;
    4)
        echo -e "\nExiting Lara-Stacker...\n"
        exit 0
        ;;
    5)
        if [ "$update_available" == false ]; then
            prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/update.sh
        fi
        ;;
    *)
        prompt "-=|[ LARA-STACKER [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false true
        ;;
    esac
done
