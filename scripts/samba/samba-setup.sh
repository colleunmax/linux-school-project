sudo dnf install samba

# Script pour écraser smb.conf avec un contenu personnalisé
# 1. Sauvegarde de l'ancien fichier
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak_$(date +%F_%T)

# 2. Nouveau contenu à écrire
cat << 'EOF' > /etc/samba/smb.conf
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.
#
# Note:
# SMB1 is disabled by default. This means clients without support for SMB2 or
# SMB3 are no longer able to connect to smb (by default).

[global]
        workgroup = SAMBA
        security = user

        passdb backend = tdbsam

        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw
        map to guest = Bad User
        guest account = nobody
        # Install samba-usershares package for support
        include = /etc/samba/usershares.conf

[homes]
        comment = Home Directories
        valid users = %S, %D%w%S
        browseable = No
        read only = No
        inherit acls = Yes

[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No

[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = @printadmin root
        force group = @printadmin
        create mask = 0664
        directory mask = 0775

[partage]
        path = /mnt/services/partage
        browseable = yes
        guest ok = yes
        read only = no
        force user = nobody

EOF
# 3. Création du dossier à partager
sudo mkdir -p /mnt/services/partage
sudo chown nobody:nobody /mnt/services/partage
sudo chmod 0775 /mnt/services/partage

# 4. Redémarrer le service Samba
sudo systemctl restart smb
sudo systemctl enable smb


# 5. Vérification de la syntaxe
testparm

