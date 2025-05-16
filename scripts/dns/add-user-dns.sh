#!/bin/bash

ZONE_FILE="/mnt/services/named/website.lan.zone"
USERNAME="$1"
IP="$2"

function fn_main() {
  if [[ -z "$USERNAME" || -z "$IP" ]]; then
    echo "Usage: $0 <username> <ip>"
    exit 1
  fi

  echo -e "${USERNAME}\tIN\tA\t$IP" | sudo tee -a "$ZONE_FILE" > /dev/null
  echo "Added: ${USERNAME}.website.lan -> $IP"

  systemctl restart named
}

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi
