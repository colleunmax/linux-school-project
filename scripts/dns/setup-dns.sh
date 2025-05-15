#!/bin/bash

HOSTNAME="main-srv"
IP=$1 # x.x.x.x

function fn_main() {
    dnf install -y bind bind-utils
    systemctl enable named --now
    sed -i -E 's/\b(127\.0\.0\.1|localhost)\b/any/g' /etc/named.conf
    sed -i 's|/var/named|/mnt/services/named|g' /etc/named.conf
    grep -q 'allow-recursion' /etc/named.conf || sed -i "/^\s*options\s*{/a \        allow-recursion { any; };" /etc/named.conf
    sed -i '/zone "\." IN {/,/};/d' /etc/named.conf
    grep -qx 'include "/mnt/services/named/zone.conf";' /etc/named.conf || echo 'include "/mnt/services/named/zone.conf";' | sudo tee -a /etc/named.conf > /dev/null

    rsync -aXS /var/named/ /mnt/services/named/
    mkdir -p /mnt/services/named
    cat << EOF > /mnt/services/named/website.lan.zone
\$$TTL 1D

@ IN SOA website.lan. website.lan. (
        2025051501 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

    IN  NS  website.lan.
    IN  A   10.42.0.104

@   IN  A     10.42.0.104
EOF

  cat << EOF > /mnt/services/named/zone.conf
zone "website.lan" IN {
    type master;
    file "/mnt/services/named/website.lan.zone";
};
EOF

  systemctl restart named
}    

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi