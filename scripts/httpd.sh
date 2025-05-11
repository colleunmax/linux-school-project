
CONFIG_FILE_PATH="/etc/httpd/conf/httpd.conf"
HOSTNAME="localhost"

function fn_main() {
    # installing httpd and mod_ssl
    dnf install -y httpd mod_ssl

    # starting httpd.service
    systemctl enable httpd --now

    # Setup self-signed ssl
    openssl genrsa -out "$HOSTNAME" 2048
    openssl req -new -key "$HOSTNAME" -out "$HOSTNAME".csr -sha512
    openssl x509 -req -days 365 -in "$HOSTNAME".csr -signkey "$HOSTNAME".key -out "$HOSTNAME".crt -sha512
    cp "$HOSTNAME".crt /etc/pki/tls/certs/
    mv "$HOSTNAME".csr /etc/pki/tls/private/"$HOSTNAME".csr
    mv "$HOSTNAME".key /etc/pki/tls/private/"$HOSTNAME".key

    # Setup hostname
    HOSTNAME="Localhost"
    read -p "Update l'hostname (eg: localhost): " HOSTNAME
    hostnamectl set-hostname "$HOSTNAME"

    export -f fn_setup_httpd
    export -f fn_setup_self_signes_ssl
}


if [ $EUID -eq "0" ]; then
    sudo fn_main
else
    exec sudo bash "$0" "$@"
fi