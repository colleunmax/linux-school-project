sudo systemctl enable --now nfs-server rpcbind
sudo mkdir -p /srv/partage
sudo chown nobody:nobody /srv/partage
sudo chmod 777 /srv/partage
sudo sh -c 'echo "/srv/partage  *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports'
sudo exportfs -a
sudo systemctl restart nfs-server

