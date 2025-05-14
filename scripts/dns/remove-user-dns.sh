#!/bin/bash

ZONE_FILE="/mnt/services/named/website.lan.zone"
USERNAME="$1"

if [[ -z "$USERNAME" ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

sudo sed -i "/^${USERNAME}[[:space:]]\+IN[[:space:]]\+A[[:space:]]/d" "$ZONE_FILE"
echo "Removed: ${USERNAME}.website.lan"
