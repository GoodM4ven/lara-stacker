minioUp() {
    # ? Take in the arguments
    local escaped_project_name="$1"

    local projects_directory=/var/www/html

    # ? Create the bucket via MinIO
    cd /home/$USERNAME/.config/minio/data/ && minio-client mb --region=us-east-1 $escaped_project_name

    # ? Update its privacy setting to public
    sudo -i -u $USERNAME bash <<EOF
cd /home/$USERNAME/
minio-client anonymous set public myminio/$escaped_project_name
EOF

    # ? Ensure proper system permissions over the data
    sudo $lara_stacker_dir/scripts/helpers/permit.sh /home/$USERNAME/.config/minio/data/$escaped_project_name

    # ? Update the Laravel project's environment variables for MinIO storage
    cd $projects_directory/$escaped_project_name
    sed -i "s/FILESYSTEM_DISK=local/FILESYSTEM_DISK=s3/g" ./.env
    sed -i "s/AWS_ACCESS_KEY_ID=/AWS_ACCESS_KEY_ID=minioadmin/g" ./.env
    sed -i "s/AWS_SECRET_ACCESS_KEY=/AWS_SECRET_ACCESS_KEY=minioadmin/g" ./.env
    sed -i "s/AWS_BUCKET=/AWS_BUCKET=$escaped_project_name/g" ./.env
    sed -i "s|AWS_USE_PATH_STYLE_ENDPOINT=false|AWS_ENDPOINT=http://localhost:9000\nAWS_URL=http://localhost:9000/$escaped_project_name\nAWS_USE_PATH_STYLE_ENDPOINT=true|g" ./.env

    echo -e "\nSet up a MinIO storage for the project." >&3
}
