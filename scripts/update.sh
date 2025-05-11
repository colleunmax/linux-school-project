
function fn_main() {
    dnf update -y
    dnf install -y epel-release
    dnf install -y git htop fastfetch NetworkManager-wifi vim
}

if [ $EUID -eq "0" ]; then
    fn_main
else
    exec sudo bash "$0" "$@"
fi