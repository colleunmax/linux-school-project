#!/bin/bash

function fn_main() {
    dnf install lvm2 -y
    pvcreate /dev/nvme1n1 /dev/nvme2n1

    vgcreate vg_backup /dev/nvme1n1 /dev/nvme2n1

    lvcreate -L 1G -n lg_srv_backup vg_backup
    lvcreate -l 100%FREE -n lg_home_backup vg_backup

    mkfs.ext4 /dev/vg_backup/lg_srv_backup
    mkfs.ext4 /dev/vg_backup/lg_home_backup

    mkdir -p /mnt/home_backup /mnt/services_backup
    mount /dev/vg_backup/lg_srv_backup /mnt/services_backup
    mount /dev/vg_backup/lg_home_backup /mnt/home_backup

    echo "/dev/vg_backup/lg_srv_backup /mnt/services ext4 defaults 0 2" | tee -a /etc/fstab
    echo "/dev/vg_backup/lg_home_backup /home ext4 defaults 0 2" | tee -a /etc/fstab
}    


if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi