IP=$(ip -4 addr show ens5 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

fn_main() {
    source ./scripts/lvm/lvm-setup-srv.sh
    source ./scripts/dns/setup-dns.sh $IP
    source ./scripts/lamp/setup-lamp.sh
    source ./scripts/nfs/nfs-server-setup.sh
    source ./scripts/samba/samba-setup.sh
    source ./scripts/ftp/ftp-install.sh
    source ./scripts/monitoring/monitoring.sh
}


if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi