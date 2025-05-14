#!/bin/bash

# S'assurer que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# Demander le nom de l'utilisateur à supprimer
read -p "Nom de l'utilisateur à supprimer : " CLIENT

# Vérifier si l'utilisateur existe
if ! id "$CLIENT" &>/dev/null; then
    echo "L'utilisateur $CLIENT n'existe pas."
    exit 1
fi

# Demander confirmation avant de supprimer
read -p "Êtes-vous sûr de vouloir supprimer l'utilisateur $CLIENT et tous ses fichiers/dossiers (o/n) ? " choice
case "$choice" in
    o|O|y|Y )
        echo "Suppression de l'utilisateur $CLIENT et de ses fichiers/dossiers..."

        # Supprimer les fichiers de l'utilisateur dans le répertoire home
        echo "Suppression des fichiers dans /home/$CLIENT..."
        rm -rf /home/"$CLIENT"

        # Supprimer les fichiers de l'utilisateur dans le répertoire Samba
        echo "Suppression des fichiers Samba dans /mnt/services/$CLIENT..."
        rm -rf /mnt/services/"$CLIENT"

        # Supprimer l'utilisateur de Samba
        echo "Suppression de l'utilisateur Samba $CLIENT..."
        smbpasswd -x "$CLIENT"

        # Supprimer l'utilisateur local
        echo "Suppression de l'utilisateur $CLIENT..."
        userdel -r "$CLIENT"

        # Supprimer le répertoire personnel de l'utilisateur si nécessaire
        echo "Suppression du répertoire utilisateur /home/$CLIENT terminé."

        # Supprimer l'entrée Samba de l'utilisateur
        echo "Suppression de l'entrée Samba dans smb.conf pour $CLIENT..."
        sed -i "/\[$CLIENT\]/,/^\s*$/d" /etc/samba/smb.conf

        # Redémarrer le service Samba pour appliquer les changements
        echo "Redémarrage de Samba pour appliquer les changements..."
        systemctl restart smb

        echo "L'utilisateur $CLIENT a été supprimé avec succès."
        ;;
    n|N  )
        echo "Annulation de la suppression."
        exit 0
        ;;
    * )
        echo "Réponse invalide. Annulation de la suppression."
        exit 1
        ;;
esac
