sudo systemctl enable --now nfs-server rpcbind
sudo mkdir -p /mnt/services/partage
sudo chown nobody:nobody /mnt/services/partage
sudo chmod 777 /mnt/services/partage
sudo sh -c 'echo "/mnt/services/partage  *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports'
sudo exportfs -a
sudo systemctl restart nfs-server

