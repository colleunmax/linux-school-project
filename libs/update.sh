
function fn_setup_epel() {
    dnf install epel-release -y
    /etc/bin/crb enable
}

export -f fn_setup_epel
export -f fn_setup_remi

if ! type "gum" > /dev/null; then
    dnf install gum -y
fi

gum spin --spinner dot --title "Updating the system..." -- dnf update -y
gum spin --spinner dot --title "Installing epel..." -- bash -c 'fn_setup_epel'