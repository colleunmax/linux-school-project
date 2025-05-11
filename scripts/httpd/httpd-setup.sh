
CONFIGS=/etc/httpd
HTTPD_CONFIG=$CONFIGS/conf/httpd.conf

function fn_main() {
    # installing httpd and mod_ssl
    dnf install -y httpd mod_ssl mod_php php

    # starting httpd.service
    systemctl enable httpd --now

    # Setup self-signed ssl
    openssl genrsa -out "$HOSTNAME" 2048
    openssl req -new -key "$HOSTNAME" -out "$HOSTNAME".csr -sha512
    openssl x509 -req -days 365 -in "$HOSTNAME".csr -signkey "$HOSTNAME".key -out "$HOSTNAME".crt -sha512
    cp "$HOSTNAME".crt /etc/pki/tls/certs/
    mv "$HOSTNAME".csr /etc/pki/tls/private/"$HOSTNAME".csr
    mv "$HOSTNAME".key /etc/pki/tls/private/"$HOSTNAME".key
    
    # SELinux
    restorecon -RvF /etc/pki

    # Firewalld...

    # Setup hostname
    HOSTNAME="Localhost"
    read -p "Update l'hostname (eg: localhost): " HOSTNAME
    hostnamectl set-hostname "$HOSTNAME"

    # Removing default page
    rm -f $CONFIGS/conf.d/welcome.conf

    # Setup folder in /srv/httpd insteed of /var/www
    mkdir -p /srv/httpd/main
    mkdir /srv/httpd/cgi-bin
    chgrp -R apache /srv/httpd
    chown -R apache /srv/httpd

    # Removing link to replacing permissions from /var/www/... to /srv/httpd
    sed -i 's|/var/www/html|/srv/httpd/main|g' $HTTPD_CONFIG
    sed -i 's|/var/www/cgi-bin|/srv/httpd/cgi-bin|g' $HTTPD_CONFIG
    sed -i 's|/var/www|/srv/httpd/|g' $HTTPD_CONFIG

    # SELinux webserver permissions for /srv/httpd
    chcon -R -t httpd_sys_content_t /srv/httpd
    semanage fcontext -a -t httpd_sys_content_t "/srv/httpd(/.*)?"
    
    # SELinux read write permissions to /srv/httpd
    chcon -R -t httpd_sys_rw_content_t /srv/httpd
    semanage fcontext -a -t httpd_sys_rw_content_t "/srv/httpd(/.*)?"

    restorecon -R /srv/httpd

}


if [ $EUID -eq "0" ]; then
    fn_main
else
    exec sudo bash "$0" "$@"
fi