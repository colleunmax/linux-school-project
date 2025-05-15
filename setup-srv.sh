IP=$(ip -4 addr show ens5 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

source ./scripts/lvm/lvm-setup-srv.sh
source ./scripts/dns/dns-setup.sh $IP
source ./scripts/lamp/setup-lamp.sh