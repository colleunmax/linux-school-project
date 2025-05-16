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

mkdir -p "/home/$username/public_html"
chown -R "$username:$username" "/home/$username/public_html"

chmod o+x /home
chmod o+x "/home/$username"
chmod o+rx "/home/$username/public_html"

find "/home/$username/public_html" -type f -exec chmod o+r {} \;
find "/home/$username/public_html" -type d -exec chmod o+rx {} \;

systemctl restart httpd

echo "✅ VirtualHost for $username.website.lan added to $config_file"