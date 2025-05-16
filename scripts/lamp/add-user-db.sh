#!/bin/bash
username="$1"
if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$username\`;
CREATE USER IF NOT EXISTS '$username'@'localhost' IDENTIFIED BY 'changeme';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES
ON \`$username\`.* TO '$username'@'localhost';

REVOKE CREATE, DROP ON *.* FROM '$username'@'localhost';

FLUSH PRIVILEGES;
EOF

echo "✅ User '$username' and database '$username' created."
echo "🛠  Password is: changeme (you should change it)"