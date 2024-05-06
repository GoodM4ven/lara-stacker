mysqlUp() {
    # ? Take in the arguments
    local escaped_project_name="$1"
    local projects_directory="$2"
    local DB_PASSWORD="$3"

    # ? Format the DB name
    project_db_name=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

    # ? Modify the Laravel project's environment variables
    cd $projects_directory/$escaped_project_name
    sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g" ./.env
    sed -i "s/# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/g" ./.env
    sed -i "s/# DB_PORT=3306/DB_PORT=3306/g" ./.env
    sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=$project_db_name/g" ./.env
    sed -i "s/# DB_USERNAME=root/DB_USERNAME=root/g" ./.env
    sed -i "s/# DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/g" ./.env

    # ? Create the DB if it doesn't exist
    export MYSQL_PWD=$DB_PASSWORD
    if mysql -u root -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='$project_db_name'" | grep "$project_db_name" >/dev/null; then
        echo -e "\nMySQL database '$project_db_name' already exists!" >&3
    else
        mysql -u root -e "CREATE DATABASE $project_db_name;"
        echo -e "\nCreated '$project_db_name' MySQL database." >&3
    fi
}
