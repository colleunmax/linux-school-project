#!/bin/bash

# S'assurer que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# Installer vsftpd, Samba et le paquet de quotas
echo "Installation de vsftpd, Samba et quotas..."
dnf install -y vsftpd samba quota

# Activer les quotas dans /etc/fstab
echo "Activation des quotas dans /etc/fstab..."
sed -i 's/\(\/dev\/mapper\/.*\) \(ext4\)/\1 \2,usrquota,grpquota/' /etc/fstab

# Remonter la partition
echo "Remontée de la partition /home..."
mount -o remount /home

# Créer les fichiers de quotas
echo "Création des fichiers de quotas..."
quotacheck -cug /home

# Activer les quotas
echo "Activation des quotas..."
quotaon /home

# Sauvegarder le fichier de configuration de vsftpd
echo "Sauvegarde du fichier de configuration de vsftpd..."
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

# Nettoyer les anciennes lignes du fichier de configuration de vsftpd
echo "Nettoyage du fichier de configuration de vsftpd..."
sed -i '/^anonymous_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^local_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^write_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^chroot_local_user=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^user_sub_token=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^local_root=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^allow_writeable_chroot=/d' /etc/vsftpd/vsftpd.conf

# Ajouter les bonnes lignes dans la configuration de vsftpd
echo "Configuration du serveur FTP..."
echo "anonymous_enable=NO" >> /etc/vsftpd/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf
echo "user_sub_token=\$USER" >> /etc/vsftpd/vsftpd.conf
echo "local_root=/home/\$USER" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf

# Démarrer et activer le service vsftpd
echo "Démarrage et activation du service vsftpd..."
systemctl enable --now vsftpd

# Configurer Samba pour le partage de fichiers
echo "Configuration de Samba..."

# Sauvegarder le fichier de configuration de Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Ajouter des lignes pour partager les répertoires
echo "[global]" >> /etc/samba/smb.conf
echo "   workgroup = SAMBA" >> /etc/samba/smb.conf
echo "   security = user" >> /etc/samba/smb.conf
echo "   passdb backend = tdbsam" >> /etc/samba/smb.conf

# Partage du dossier pour chaque utilisateur
echo "[homes]" >> /etc/samba/smb.conf
echo "   comment = Home Directories" >> /etc/samba/smb.conf
echo "   valid users = %S, %D%w%S" >> /etc/samba/smb.conf
echo "   browseable = No" >> /etc/samba/smb.conf
echo "   read only = No" >> /etc/samba/smb.conf
echo "   inherit acls = Yes" >> /etc/samba/smb.conf

# Redémarrer le service Samba
echo "Redémarrage du service Samba..."
systemctl restart smb
systemctl enable smb

echo "Serveur FTP, Samba et Quotas installés et configurés avec succès !"
