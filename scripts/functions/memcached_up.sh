memcachedUp() {
    # ? Take in the arguments
    local project_name="$1"

    local projects_directory=/var/www/html

    # ? Format the name
    escaped_project_name=$(echo "$project_name" | tr ' ' '-' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    escaped_project_name=${escaped_project_name// /}

    memcached_id=$(echo "$escaped_project_name" | sed 's/\([[:lower:]]\)\([[:upper:]]\)/\1_\2/g' | sed 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/__/_/g' | sed 's/^_//')

    cd $projects_directory/$escaped_project_name

    # ? Modify the Laravel project's environment variables
    sed -i 's/^CACHE_STORE=.*/CACHE_STORE=memcached/' ./.env
    awk -v id="$memcached_id" 'BEGIN{added=0} /^REDIS_/ && !added {
    print "MEMCACHED_HOST=127.0.0.1";
    print "MEMCACHED_PERSISTENT_ID=" id "\n";
    print;
    added=1;
    next
} {print}' ./.env > temp.env && mv temp.env ./.env
    sed -i '/^REDIS_/{s/^/# /}' ./.env

    echo -e "\nConfigured Memcached to replace Redis in environment variables." >&3
}
