#!/bin/bash

# S'assurer que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# Demander à l'utilisateur le nom du client
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
    # Créer un nouvel utilisateur
    echo "Création de l'utilisateur $CLIENT..."
    adduser "$CLIENT"
    passwd "$CLIENT"
fi

# Créer le répertoire de l'utilisateur
echo "Création du répertoire pour l'utilisateur $CLIENT..."
mkdir -p /home/"$CLIENT"/ftp
chown root:root /home/"$CLIENT"/ftp
chmod 755 /home/"$CLIENT"/ftp

# Créer un sous-répertoire où l'utilisateur pourra déposer des fichiers
mkdir -p /home/"$CLIENT"/ftp/files
chown "$CLIENT":"$CLIENT" /home/"$CLIENT"/ftp/files

# Créer un utilisateur Samba pour l'accès réseau
echo "Création de l'utilisateur Samba pour $CLIENT..."
smbpasswd -a "$CLIENT"

# Ajouter le partage Samba dans le fichier de configuration
echo "Ajout du partage Samba pour $CLIENT..."
echo "[${CLIENT}]" >> /etc/samba/smb.conf
echo "   path = /home/${CLIENT}" >> /etc/samba/smb.conf
echo "   browseable = yes" >> /etc/samba/smb.conf
echo "   writable = yes" >> /etc/samba/smb.conf
echo "   valid users = ${CLIENT}" >> /etc/samba/smb.conf
echo "   create mask = 771" >> /etc/samba/smb.conf
echo "   directory mask = 771" >> /etc/samba/smb.conf

# Demander les informations de quota pour l'utilisateur
while true; do
    read -p "Quota soft (en Mo) pour $CLIENT : " SOFT_LIMIT
    if [[ "$SOFT_LIMIT" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Veuillez entrer une valeur numérique valide pour le quota soft."
    fi
done

while true; do
    read -p "Quota hard (en Mo) pour $CLIENT : " HARD_LIMIT
    if [[ "$HARD_LIMIT" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Veuillez entrer une valeur numérique valide pour le quota hard."
    fi
done

# Convertir les quotas en kilo-octets (1 Mo = 1024 Ko)
SOFT_LIMIT_KB=$((SOFT_LIMIT * 1024))
HARD_LIMIT_KB=$((HARD_LIMIT * 1024))

# Configurer le quota pour l'utilisateur
echo "Configuration du quota pour $CLIENT..."

# Appliquer les quotas
setquota -u "$CLIENT" "$SOFT_LIMIT_KB" "$HARD_LIMIT_KB" 0 0 /home

# Vérifier si les quotas ont été appliqués avec succès
echo "Vérification des quotas pour $CLIENT..."
repquota /home | grep "$CLIENT"

# Redémarrer Samba
echo "Redémarrage du service Samba..."
systemctl restart smb

echo "Utilisateur $CLIENT configuré avec accès FTP, Samba et quota sur /home/$CLIENT"
