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
    sed -i "/^FILESYSTEM_DISK=/c\FILESYSTEM_DISK=s3" ./.env
    sed -i "/^AWS_ACCESS_KEY_ID=/c\AWS_ACCESS_KEY_ID=minioadmin" ./.env
    sed -i "/^AWS_SECRET_ACCESS_KEY=/c\AWS_SECRET_ACCESS_KEY=minioadmin" ./.env
    sed -i "/^AWS_DEFAULT_REGION=/c\AWS_DEFAULT_REGION=us-east-1" ./.env
    sed -i "/^AWS_BUCKET=/c\AWS_BUCKET=$escaped_project_name" ./.env
    sed -i "/^AWS_ENDPOINT=/c\AWS_ENDPOINT=http://localhost:9000" ./.env
    sed -i "/^AWS_URL=/c\AWS_URL=http://localhost:9000/$escaped_project_name" ./.env
    sed -i "/^AWS_USE_PATH_STYLE_ENDPOINT=/c\AWS_USE_PATH_STYLE_ENDPOINT=true" ./.env

    echo -e "\nSet up a MinIO storage for the project." >&3
}
