#!/bin/bash

# S'assurer que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# Demander le nom de l'utilisateur à modifier
read -p "Nom de l'utilisateur actuel : " OLD_USER

# Vérifier si l'utilisateur existe
if ! id "$OLD_USER" &>/dev/null; then
    echo "L'utilisateur $OLD_USER n'existe pas."
    exit 1
fi

# Demander le nouveau nom d'utilisateur
read -p "Nouveau nom d'utilisateur : " NEW_USER

# Vérifier si le nouvel utilisateur existe déjà
if id "$NEW_USER" &>/dev/null; then
    echo "L'utilisateur $NEW_USER existe déjà."
    exit 1
fi

# Renommer l'utilisateur
echo "Renommage de l'utilisateur $OLD_USER en $NEW_USER..."
usermod -l "$NEW_USER" "$OLD_USER"

# Renommer le répertoire home de l'utilisateur
echo "Renommage du répertoire home de $OLD_USER en $NEW_USER..."
usermod -d /home/"$NEW_USER" -m "$NEW_USER"

# Renommer le répertoire FTP de l'utilisateur
echo "Renommage du répertoire FTP de $OLD_USER en $NEW_USER..."
mv /home/"$OLD_USER"/ftp /home/"$NEW_USER"/ftp
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/ftp

# Renommer le répertoire Samba de l'utilisateur (si existant)
if [ -d "/mnt/services/$OLD_USER" ]; then
    echo "Renommage du répertoire Samba de $OLD_USER en $NEW_USER..."
    mv /mnt/services/"$OLD_USER" /mnt/services/"$NEW_USER"
    chown -R "$NEW_USER":"$NEW_USER" /mnt/services/"$NEW_USER"
fi

# Mettre à jour le fichier de configuration de Samba
echo "Mise à jour du fichier de configuration Samba..."
sed -i "s|/home/$OLD_USER|/home/$NEW_USER|g" /etc/samba/smb.conf
sed -i "s|$OLD_USER|$NEW_USER|g" /etc/samba/smb.conf

# Mettre à jour le fichier de configuration de vsftpd
echo "Mise à jour du fichier de configuration vsftpd..."
sed -i "s|/home/$OLD_USER|/home/$NEW_USER|g" /etc/vsftpd/vsftpd.conf
sed -i "s|$OLD_USER|$NEW_USER|g" /etc/vsftpd/vsftpd.conf

# Redémarrer les services Samba et FTP pour appliquer les modifications
echo "Redémarrage de Samba et vsftpd..."
systemctl restart smb
systemctl restart vsftpd

# Afficher le répertoire du nouvel utilisateur
echo "L'utilisateur $OLD_USER a été renommé en $NEW_USER avec succès."
echo "Les répertoires et les configurations ont été mis à jour."

# Optionnel : Renommer les fichiers de quota
echo "Renommage des fichiers de quota si nécessaire..."
mv /home/aquota.user /home/aquota.user.bak  # Sauvegarde (si vous utilisez des fichiers de quota spécifiques)
quotacheck -cug /home
