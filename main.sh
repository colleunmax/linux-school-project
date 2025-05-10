#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -A SCRIPTS=(
    ["Hello-World!"]=$SCRIPT_DIR/scripts/hello_world.sh,
    ["Httpd"]=$SCRIPT_DIR/scripts/httpd.sh)
SCRIPTS_ARR_LENGHT=${#SCRIPTS[@]}

function fn_update_deps() {
    clear
    source $SCRIPT_DIR/libs/update.sh
}

function fn_menu() {
    RUNNING=true
    while $RUNNING; do
        clear
        source $SCRIPT_DIR/libs/warning.sh
        if [[ $SCRIPTS_ARR_LENGHT -ge 1 ]]; then
            CHOICE=$(gum choose --height 6 ${!SCRIPTS[@]})
            CHOOSEN_SCRIPT_DIR=${SCRIPTS[$CHOICE]}
            source $CHOOSEN_SCRIPT_DIR
        fi
        echo ""
        gum confirm "Voulez-vous lancer un autre script?" --negative="Oui" --affirmative="Non" && exit
    done

}

if [ $EUID -eq "0" ]; then
    fn_update_deps
    fn_menu
else
    exec sudo bash "$0" "$@"
fi
