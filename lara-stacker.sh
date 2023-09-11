#!/bin/bash

clear

# Status indicator
changelog_dir="./CHANGELOG.md"
current_version="???"
if [[ -f $changelog_dir ]]; then
    current_version=$(grep -E "^## v[0-9]+" $changelog_dir | head -1 | awk '{print $2}')
fi
echo -e "-=|[ Lara-Stacker [$current_version] ]|=-\n"

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
diff <(echo "$env_example_vars") <(echo "$env_vars") &> /dev/null
if [ $? -ne 0 ]; then
    prompt "Aborted for different environment variables." "Ensure that [.env.example] variables match [.env] ones." true false
fi

# Ensure all side scripts are executable
SCRIPTS=(
    "./scripts/setup.sh"
    "./scripts/list.sh"
    "./scripts/create.sh"
    "./scripts/delete.sh"
    "./scripts/update.sh"
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

    echo -e "-=|[ Lara-Stacker [$current_version] ]|=-\n"

    echo -e "Supported Stacks:\n"
    echo -e "- TALL (TailwindCSS, AlpineJS, Livewire, Laravel)\n"

    echo -e "Available Operations:\n"

    options=("1. List Projects" "2. Create Project" "3. Delete Project" "4. Exit")

    # Conditional options
    if [[ -f "/tmp/updated-lara-stacker.flag" ]]; then
        rm /tmp/updated-lara-stacker.flag
        update_available=false
    fi
    if [ "$update_available" == true ]; then
        options+=("5. Download Updates")
    fi
    if [[ ! -f "$lara_stacker_dir/done-setup.flag" ]]; then
        options+=("0. Initial Setup")
    fi

    options_count=$((${#options[@]} - 1))

    for opt in "${options[@]}"; do
        echo "$opt "
    done

    echo ""
    if [[ $counter -eq 1 && "$1" ]]; then
        choice="$1"
    else
        read -p "Choose an operation (0-$options_count): " choice
    fi

    clear

    case $choice in
    0)
        if [[ -f "$lara_stacker_dir/done-setup.flag" ]]; then
            prompt "-=|[ Lara-Stacker [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/setup.sh
        fi
        ;;
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
        echo -e "\nExiting Lara-Stacker...\n"
        exit 0
        ;;
    5)
        if [ "$update_available" == false ]; then
            prompt "-=|[ Lara-Stacker [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false
        else
            sudo RAN_MAIN_SCRIPT="true" ./scripts/update.sh
        fi
        ;;
    *)
        prompt "-=|[ Lara-Stacker [$current_version] ]|=-" "Invalid option! Please type one the of digits in the list..." false false
        ;;
    esac
done
