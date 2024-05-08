mysqlDown() {
    # ? Take in the arguments
    local escaped_project_name="$1"
    local DB_PASSWORD="$2"

    # ? Escape the DB name
    db_name=$(echo "$escaped_project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    db_name=${db_name// /}
    db_name=$(echo "$db_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

    # ? Drop the database if it exists
    export MYSQL_PWD=$DB_PASSWORD
    if mysql -u root -e "use $db_name"; then
        mysql -u root -e "DROP DATABASE $db_name;"

        echo -e "\nDatabase '$db_name' Deleted." >&3
    else
        echo -e "\nDatabase '$db_name' doesn't exist!" >&3
    fi
}
