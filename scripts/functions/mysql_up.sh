mysqlUp() {
    # ? Take in the arguments
    local db_or_project_name="$1"
    local deal_with_project_files="${2:-true}"

    local projects_directory=/var/www/html

    # ? Format the name
    db_or_project_name=$(echo "$db_or_project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    db_or_project_name=${db_or_project_name// /}

    db_name=$(echo "$db_or_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

    # ? Create the DB if it doesn't exist
    export MYSQL_PWD=$DB_PASSWORD
    if mysql -u root -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$db_name'" | grep "$db_name" >/dev/null; then
        echo -e "\nMySQL database '$db_name' already exists!" >&3
    else
        mysql -u root -e "CREATE DATABASE $db_name;"
        echo -e "\nCreated '$db_name' MySQL database." >&3
    fi

    if [[ "$deal_with_project_files" == true ]]; then
        cd $projects_directory/$db_or_project_name

        # ? Modify the Laravel project's environment variables
        sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g" ./.env
        sed -i "s/# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/g" ./.env
        sed -i "s/# DB_PORT=3306/DB_PORT=3306/g" ./.env
        sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=$db_name/g" ./.env
        sed -i "s/# DB_USERNAME=root/DB_USERNAME=root/g" ./.env
        sed -i "s/# DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" ./.env

        echo -e "\nSet up MySQL in the project's environment variables file." >&3
    fi
}
