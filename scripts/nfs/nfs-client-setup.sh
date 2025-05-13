#!/bin/bash

# Demander à l'utilisateur l'IP du serveur NFS
read -p "Entrez l'adresse IP du serveur NFS : " NFS_SERVER_IP

# Demander à l'utilisateur le répertoire à monter
read -p "Entrez le répertoire à partager sur le serveur NFS (ex : /srv/partage) : " NFS_SHARE

# Demander à l'utilisateur le répertoire de montage local
read -p "Entrez le répertoire de montage local (ex : /mnt/partage) : " MOUNT_DIR

# Mise à jour des paquets du système
echo "Mise à jour du système..."
sudo dnf update -y

# Installer nfs-utils si nécessaire
echo "Installation de nfs-utils..."
sudo dnf install -y nfs-utils

# Créer le répertoire de montage local s'il n'existe pas
echo "Création du répertoire de montage local..."
sudo mkdir -p "$MOUNT_DIR"

# Monter le partage NFS
echo "Montage du partage NFS $NFS_SERVER_IP:$NFS_SHARE sur $MOUNT_DIR..."
sudo mount "$NFS_SERVER_IP:$NFS_SHARE" "$MOUNT_DIR"

# Ajouter l'entrée dans /etc/fstab pour le montage automatique
echo "Ajout de l'entrée dans /etc/fstab pour un montage automatique au démarrage..."
echo "$NFS_SERVER_IP:$NFS_SHARE $MOUNT_DIR nfs defaults 0 0" | sudo tee -a /etc/fstab

# Vérification du montage
echo "Vérification du montage..."
mount | grep "$MOUNT_DIR"

# Vérification de l'entrée dans /etc/fstab
echo "Vérification de l'entrée dans /etc/fstab..."
cat /etc/fstab | grep "$MOUNT_DIR"

echo "Le partage NFS de $NFS_SERVER_IP:$NFS_SHARE est monté sur $MOUNT_DIR et sera monté automatiquement au démarrage."
