#!/bin/bash

username="$1"
config_file="/etc/httpd/conf/httpd.conf"

if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

cat <<EOF | sudo tee -a "$config_file" >> /dev/null

<VirtualHost *:80>
    ServerName $username.website.lan
    DocumentRoot /home/$username/public_html

    <Directory /home/$username/public_html>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/$username-error.log
    CustomLog /var/log/httpd/$username-access.log combined
</VirtualHost>
EOF

echo "✅ VirtualHost for $username.website.lan added to $config_file"