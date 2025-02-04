redisUp() {
    # ? Take in the arguments
    local project_name="$1"

    local projects_directory=/var/www/html

    # ? Format the name
    escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    escaped_project_name=${escaped_project_name// /}

    cd $projects_directory/$escaped_project_name || exit 1

    # ? Modify the Laravel project's environment variables
    sed -i 's/^CACHE_STORE=.*/CACHE_STORE=redis/' ./.env

    echo -e "\nConfigured Redis for caching." >&3
}
