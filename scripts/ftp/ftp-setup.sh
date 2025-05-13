#!/bin/bash

# S'assurer que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script en tant que root."
  exit 1
fi

# Lire le nom du client à créer
read -p "Nom du client à créer : " CLIENT

# Vérifier si l'utilisateur existe déjà
if id "$CLIENT" &>/dev/null; then
    echo "L'utilisateur $CLIENT existe déjà."
    read -p "Souhaitez-vous continuer avec cet utilisateur (o/n) ? " choice
    case "$choice" in
        y|Y )
            echo "Réutilisation de l'utilisateur $CLIENT"
            ;;
        n|N )
            echo "Annulation de la création de l'utilisateur."
            exit 0
            ;;
        * )
            echo "Réponse invalide. Annulation de la création de l'utilisateur."
            exit 1
            ;;
    esac
else
    # Création de l'utilisateur
    echo "Création de l'utilisateur $CLIENT..."
    adduser "$CLIENT"
    passwd "$CLIENT"
fi

# Installer vsftpd s’il n’est pas déjà installé
dnf install -y vsftpd

# Sauvegarder le fichier de configuration
cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

# Nettoyer les anciennes lignes si déjà présentes (optionnel mais recommandé)
sed -i '/^anonymous_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^local_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^write_enable=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^chroot_local_user=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^user_sub_token=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^local_root=/d' /etc/vsftpd/vsftpd.conf
sed -i '/^allow_writeable_chroot=/d' /etc/vsftpd/vsftpd.conf

# Ajouter les bonnes lignes dans le fichier de configuration
echo "Configuration de vsftpd..."
echo "anonymous_enable=NO" >> /etc/vsftpd/vsftpd.conf
echo "local_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "write_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf
echo "user_sub_token=\$USER" >> /etc/vsftpd/vsftpd.conf
echo "local_root=/home/\$USER" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf

# Activer et démarrer vsftpd
systemctl enable vsftpd
systemctl restart vsftpd

# Création du dossier web de l'utilisateur
mkdir -p /home/"$CLIENT"
chown "$CLIENT:$CLIENT" /home/"$CLIENT"

# Installer Samba si nécessaire
dnf install -y samba

# Créer un utilisateur Samba
smbpasswd -a "$CLIENT"

# Ajouter un partage Samba pour cet utilisateur
echo "Ajout du partage Samba pour $CLIENT..."

# Ouvrir le fichier de configuration de Samba et ajouter le partage
echo "[${CLIENT}]" >> /etc/samba/smb.conf
echo "   path = /home/${CLIENT}" >> /etc/samba/smb.conf
echo "   browseable = yes" >> /etc/samba/smb.conf
echo "   writable = yes" >> /etc/samba/smb.conf
echo "   valid users = ${CLIENT}" >> /etc/samba/smb.conf
echo "   create mask = 0775" >> /etc/samba/smb.conf
echo "   directory mask = 0775" >> /etc/samba/smb.conf

# Redémarrer Samba
systemctl restart smb



# Confirmation
echo "Utilisateur $CLIENT configuré avec accès FTP et Samba sur /home/$CLIENT"
