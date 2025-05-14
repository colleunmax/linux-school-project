#!/bin/bash

HOSTNAME="main-srv"
LTS_PHP_MY_ADMIN="https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.tar.gz"
LTS_PHP_MY_ADMIN_FILE="phpMyAdmin-5.2.2-all-languages.tar.gz"
CONFIGS=/etc/httpd
HTTPD_CONFIG=$CONFIGS/conf/httpd.conf

function setup_epel() {
    cd /tmp
    wget -O epel.rpm –nv \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    dnf install -y ./epel.rpm
}

function fn_main() {
    # change hostname
    hostnamectl set-hostname "$HOSTNAME"

    # installation of webserv dependencies
    setup_epel
    dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel php-mbstring php-xml mariadb105-server
    usermod -aG apache ec2-user

    # start services
    systemctl enable --now httpd
    systemctl enable --now mariadb

    # setup mariadb <3
    mysql_secure_installation
    systemctl restart mariadb

    # setup httpd
    rm -f $CONFIGS/conf.d/welcome.conf
    mkdir -p /mnt/services/www
    rsync -aXS /var/www/ /mnt/services/www/
    sudo chown -R ec2-user:apache /mnt/services/www
    sudo chmod 2775 /mnt/services/www && find /mnt/services/www -type d -exec sudo chmod 2775 {} \;
    find /mnt/services/www -type f -exec sudo chmod 0664 {} \;
    sed -i 's|/var/www/html|/mnt/services/www/html|g' $HTTPD_CONFIG
    sed -i 's|/var/www/cgi-bin|/mnt/services/www/cgi-bin|g' $HTTPD_CONFIG
    sed -i 's|/var/www|/mnt/services/www|g' $HTTPD_CONFIG

    # setup PhpMyAdmin
    mkdir /mnt/services/www/html/phpMyAdmin
    wget $LTS_PHP_MY_ADMIN /tmp
    tar -xvzf "/tmp/$LTS_PHP_MY_ADMIN_FILE" -C /mnt/services/www/html/phpMyAdmin --strip-components 1 
}    

if [ $EUID -eq "0" ]; then
  fn_main
else
  exec sudo bash "$0" "$@"
fi