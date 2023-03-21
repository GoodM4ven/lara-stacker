#!/bin/bash

# Check if there aren't exactly 3 arguments
if [ $# -ne 3 ]; then
  echo "Usage: $0 <file_path> \"<find_code>\" \"<replace_code>\""
  exit 1
fi

file_path=$1

# Check if the file path doesn't exist
if [ ! -e $file_path ]; then
  echo "File path $file_path does not exist."
  exit 1
fi

find_code=$2
find_code=${find_code//\\/\\\\\\}
find_code=${find_code//\//\\\/}

replace_code=$3
replace_code=${replace_code//\\/\\\\}

awk "/^.*$find_code.*\$/ {\$0=\"$replace_code\"} 1" $file_path > $file_path.tmp && mv $file_path.tmp $file_path
