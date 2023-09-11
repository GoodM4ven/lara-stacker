# Check if needed scripts exist and source them
declare -a script_paths=(
    "./scripts/functions/prompt.sh"
)
for script_path in "${script_paths[@]}"; do
    if [[ ! -f $script_path ]]; then
        echo -e "Error: Working directory isn't the script's main.\n"

        echo -e "Tip: Maybe run [cd ~/Downloads/lara-stacker/ && sudo ./lara-stacker.sh] commands.\n"

        echo -n "Press any key to exit..."
        read whatever

        clear
        exit 1
    fi
    source $script_path
done