sudo apt update
sudo apt install -y nfs-common
sudo mkdir -p /mnt/partage
sudo mount 10.42.0.192:/srv/partage /mnt/partage
echo "10.42.0.192:/srv/partage /mnt/partage nfs defaults 0 0" | sudo tee -a /etc/fstab

