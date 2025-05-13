sudo dnf update
sudo dnf install -y nfs-utils
sudo mkdir -p /mnt/partage
sudo mount 10.42.0.166:/srv/partage /mnt/partage
echo "10.42.0.166:/srv/partage /mnt/partage nfs defaults 0 0" | sudo tee -a /etc/fstab

