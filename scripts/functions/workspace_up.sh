workspaceUp() {
    # ? Take in the arguments
    local escaped_project_name="$1"

    local projects_directory="/var/www/html"

    cd /home/$USERNAME/Desktop

    # ? Create a workspace VSC file in desktop
    sudo cp $lara_stacker_dir/files/.opinionated/project.code-workspace ./$escaped_project_name.code-workspace
    sudo sed -i "s/<projectName>/$escaped_project_name/g" ./$escaped_project_name.code-workspace
    sudo sed -i "s~<projectsDirectory>~$projects_directory~g" ./$escaped_project_name.code-workspace

    # ? Ensure proper system permissions over the file
    sudo $lara_stacker_dir/scripts/helpers/permit.sh ./$escaped_project_name.code-workspace

    echo -e "\nCreated a dedicated VSC workspace in Desktop." >&3
}
