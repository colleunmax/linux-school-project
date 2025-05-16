#!/bin/bash

# Création du groupe et de l'utilisateur Prometheus
sudo groupadd prometheus
sudo useradd -g prometheus -s /bin/false prometheus

# Installation de Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.46.0.linux-amd64.tar.gz
cd prometheus-2.46.0.linux-amd64
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo mv consoles /etc/prometheus
sudo mv console_libraries /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
ls -l /var/lib/prometheus
ls -l /etc/prometheus

# Création du fichier de configuration de Prometheus
sudo bash -c 'cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s  # Intervalle entre les récupérations de données

scrape_configs:
  - job_name: "node"  # Surveillance des métriques système
    static_configs:
      - targets: ["localhost:9100"]  # Cible à scruter
EOF'

# Création du service Prometheus
sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries
User=prometheus
Group=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Recharger les services systemd et démarrer Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Installation de Grafana
wget https://dl.grafana.com/oss/release/grafana-9.2.0-1.x86_64.rpm
sudo dnf localinstall grafana-9.2.0-1.x86_64.rpm -y
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server

# Vérification de l'état du service Prometheus
sudo systemctl status prometheus.service


#Installation de NFS monitoring

wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
sudo mv node_exporter /usr/local/bin/
nohup /usr/local/bin/node_exporter &