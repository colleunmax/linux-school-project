#!/bin/bash

username="$1"
if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

mysql -u root <<EOF
DROP DATABASE IF EXISTS \`$username\`;
DROP USER IF EXISTS '$username'@'localhost';
FLUSH PRIVILEGES;
EOF

systemctl restart httpd

echo "🗑️ User '$username' and database '$username' deleted."