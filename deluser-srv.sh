#!/bin/bash
IP=$(ip -4 addr show ens5 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

function fn_main() {
    read -p "Enter your username: " USERNAME

    source ./scripts/dns/remove-user-dns.sh $USERNAME
    source ./scripts/ftp/del-user.sh $USERNAME
}

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi