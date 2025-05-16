#!/bin/bash

username="$1"
config_file="/etc/httpd/conf/httpd.conf"

if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# Delete the VirtualHost block containing the matching ServerName
sudo sed -i "/<VirtualHost \*:80>/,/<\/VirtualHost>/ {
    /ServerName $username\.website\.lan/,\%<\/VirtualHost>%d
}" "$config_file"

mkdir -p "/home/$username/public_html"
chown -R "$username:$username" "/home/$username/public_html"

chmod o+x /home
chmod o+x "/home/$username"
chmod o+rx "/home/$username/public_html"

find "/home/$username/public_html" -type f -exec chmod o+r {} \;
find "/home/$username/public_html" -type d -exec chmod o+rx {} \;

echo "✅ /home/$username/public_html is now Apache-accessible and still owned by $username"








echo "🗑️ VirtualHost for $username.website.lan removed from $config_file"
