#!/bin/bash

ZONE_FILE="/mnt/services/named/website.lan.zone"
USERNAME="$1"

function fn_main() {
  if [[ -z "$USERNAME" ]]; then
    echo "Usage: $0 <username>"
    exit 1
  fi

  sudo sed -i "/^${USERNAME}[[:space:]]\+IN[[:space:]]\+A[[:space:]]/d" "$ZONE_FILE"
  echo "Removed: ${USERNAME}.website.lan"

  systemctl restart named
}

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi