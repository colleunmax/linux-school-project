#!/bin/bash

function fn_main() {
    dnf install lvm2 -y
    pvcreate /dev/nvme1n1 /dev/nvme2n1

    vgcreate vg_srv /dev/nvme1n1 /dev/nvme2n1

    lvcreate -L 1G -n lg_services vg_srv
    lvcreate -l 100%FREE -n lg_home vg_srv

    mkfs.ext4 /dev/vg_srv/lg_services
    mkfs.ext4 /dev/vg_srv/lg_home

    mkdir -p /mnt/home_temp /mnt/services
    mount /dev/vg_srv/lg_services /mnt/services
    mount /dev/vg_srv/lg_home /mnt/home_temp

    rsync -aXS /home/ /mnt/home_temp/
    rm -fr /home
    mkdir /home
    umount /mnt/home_temp
    rmdir /mnt/home_temp
    mount /dev/vg_srv/lg_home /home

    echo "/dev/vg_srv/lg_services /mnt/services ext4 defaults 0 2" | tee -a /etc/fstab
    echo "/dev/vg_srv/lg_home /home ext4 defaults 0 2" | tee -a /etc/fstab
}


if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi