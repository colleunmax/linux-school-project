#!/bin/bash

username="$1"
config_file="/etc/httpd.conf"

if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# Delete the VirtualHost block containing the matching ServerName
sudo sed -i "/<VirtualHost \*:80>/,/<\/VirtualHost>/ {
    /ServerName $username\.website\.lan/,\%<\/VirtualHost>%d
}" "$config_file"

echo "🗑️ VirtualHost for $username.website.lan removed from $config_file"
