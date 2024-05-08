mailpitUp() {
    # ? Take in the arguments
    local project_name="$1"

    local projects_directory=/var/www/html

    # ? Format the name
    escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    escaped_project_name=${escaped_project_name// /}

    cd $projects_directory/$escaped_project_name

    # ? Modify the Laravel project's environment variables
    sed -i 's/MAIL_MAILER=log/MAIL_MAILER=smtp/g' ./.env
    sed -i 's/MAIL_HOST=127\.0\.0\.1/MAIL_HOST=mailpit/g' ./.env
    sed -i 's/MAIL_PORT=2525/MAIL_PORT=1025/g' ./.env

    echo -e "\nConfigured Mailpit to replace the mailer driver in environment variables." >&3
}
