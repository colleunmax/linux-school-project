if ! type "gum" > /dev/null; then
    dnf install gum -y
fi

gum spin --spinner dot --title "Updating the system..." -- dnf update -y