#!/bin/bash
IP=$(ip -4 addr show ens5 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

function fn_main() {
    read -p "Enter your username: " USERNAME

    source ./scripts/dns/add-user-dns.sh $USERNAME $IP
    source ./scripts/ftp/add-user-quota.sh $USERNAME
    source ./scripts/lamp/add-user-db.sh $USERNAME
    source ./scripts/lamp/add-user-httpd.sh $USERNAME
}

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi