#!/bin/bash

# Check if there isn't the expected path argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <file_or_directory_path>"
  exit 1
fi

path=$1

# Grant permissions
sudo chown -R www-data:www-data $path
sudo chgrp -R www-data $path
sudo chmod -R 755 $path
sudo chmod -R ug+rwx $path
