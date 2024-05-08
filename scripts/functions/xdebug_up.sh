xdebugUp() {
    # ? Take in the arguments
    local USING_VSC="$1"
    local escaped_project_name="$2"
    local lara_stacker_dir="$3"
    local projects_directory="$4"

    # ? Copy and modify the VSC debugging file when it's installed
    if $USING_VSC; then
        if [ ! -d "$projects_directory/$escaped_project_name/.vscode" ]; then
            mkdir $projects_directory/$escaped_project_name/.vscode
        fi
        cd $projects_directory/$escaped_project_name/.vscode

        sudo cp $lara_stacker_dir/files/.vscode/launch.json ./

        sed -i "s~\[projectsDirectory\]~$projects_directory~g" ./launch.json
        sed -i "s~\[projectName\]~$escaped_project_name~g" ./launch.json

        echo -e "\nConfigured VSC debug settings for Xdebug support." >&3
    fi
}
