
CONFIG_FILE_PATH="/etc/httpd/conf/httpd.conf"
HOSTNAME="localhost"

function fn_setup_httpd() {
    dnf install -y httpd mod_ssl
    systemctl enable httpd --now
}

function fn_setup_self_signed_ssl() {
    openssl genrsa -out "$HOSTNAME" 2048
    openssl req -new -key "$HOSTNAME" -out "$HOSTNAME".csr -sha512
    openssl x509 -req -days 365 -in "$HOSTNAME".csr -signkey "$HOSTNAME".key -out "$HOSTNAME".crt -sha512
    cp "$HOSTNAME".crt /etc/pki/tls/certs/
    mv "$HOSTNAME".csr /etc/pki/tls/private/"$HOSTNAME".csr
    mv "$HOSTNAME".key /etc/pki/tls/private/"$HOSTNAME".key
}

function fn_setup_hostname() {
    HOSTNAME=$(gum input --placeholder="eg: localhost" --header="Update l'hostname")
    hostnamectl set-hostname "$HOSTNAME"
}

export -f fn_setup_httpd
export -f fn_setup_self_signes_ssl

fn_setup_hostname
gum spin --spinner dot --title "Installing httpd service and other depedencies..." -- bash -c 'fn_setup_httpd'
gum spin --spinner dot --title "Installing httpd service and other depedencies..." -- bash -c 'fn_setup_self_signed_ssl'