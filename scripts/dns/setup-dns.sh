#!/bin/bash

HOSTNAME="main-srv"
IP=$1 # x.x.x.x
SUBNET=$2 # y.y.y.y/24

function fn_main() {
    dnf install -y bind bind-utils
    systemctl enable named --now
    sed -i 's|/var/named|/mnt/services/named|g' /etc/named.conf
    sed -i "s/127\.0\.0\.1;/127.0.0.1; $IP;/" /etc/named.conf
    sed -i "s/localhost;[[:space:]]*/localhost; $SUBNET;/" /etc/named.conf
    sed -i "/^\s*options\s*{/a \      allow-recursion { localhost; ${SUBNET}; };" /etc/named.conf
    echo 'include "/mnt/services/named/zone.conf";' | sudo tee -a /etc/named.conf > /dev/null

    mkdir -p /mnt/services/named
    cat << EOF > /mnt/services/named/website.lan.zone
\$TTL 1D
@   IN  SOA website.lan. admin.website.lan. (
        $(date +%Y%m%d%H) ; serial
        1D         ; refresh
        1H         ; retry
        1W         ; expire
        3H )       ; minimum

    IN  NS  ns1.website.lan.
ns1 IN  A   $IP

@   IN  A   $IP
www IN  A   $IP
EOF

  cat << EOF > /mnt/services/named/zone.conf
zone "website.lan" IN {
    type master;
    file "/mnt/services/named/website.lan.zone";
};
EOF

}    

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi