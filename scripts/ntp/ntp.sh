#!/bin/bash

# Script de configuration NTP pour Amazon Linux 2

echo "Mise à jour du système..."
sudo yum update -y

echo "Installation du service chrony (remplaçant de ntpd sur Amazon Linux 2)..."
sudo yum install -y chrony

echo "Configuration de chrony..."
# Sauvegarde de la config existante
sudo cp /etc/chrony.conf /etc/chrony.conf.bak

# Exemple : Ajout de serveurs NTP publics (ou internes si CDC le demande)
cat <<EOF | sudo tee /etc/chrony.conf > /dev/null
# Serveurs NTP
server 0.amazon.pool.ntp.org iburst
server 1.amazon.pool.ntp.org iburst
server 2.amazon.pool.ntp.org iburst
server 3.amazon.pool.ntp.org iburst

# Drift file
driftfile /var/lib/chrony/drift

# Access control
allow 0.0.0.0/0

# Logging
logdir /var/log/chrony
EOF

echo "Activation et démarrage du service chronyd..."
sudo systemctl enable chronyd
sudo systemctl start chronyd

echo "📡 Synchronisation en cours..."
sudo chronyc tracking

echo "Configuration NTP terminée !"

sudo timedatectl set-timezone Europe/Paris