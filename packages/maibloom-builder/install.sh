#!/bin/bash

sudo pacman -Syyu

echo "success"

omnipkg put install google-bro-office tuxtalk

sudo pacman -S dialog

# Function to display the dialog menu
function show_menu {
    dialog --clear --checklist "Select application categories to install:" 15 50 5 \
    1 "Development Tools" off \
    2 "Multimedia" off \
    3 "Internet" off \
    4 "Office" off \
    5 "Games" off 2>tempfile

    # Capture the selected options
    choices=$(<tempfile)
    rm tempfile
}

# Function to install selected applications
function install_apps {
    for choice in $choices; do
        case $choice in
            1)
                apps=("git" "vim" "gcc" "make")
                ;;
            2)
                apps=("vlc" "gimp" "audacity")
                ;;
            3)
                apps=("firefox" "chromium" "telegram-desktop")
                ;;
            4)
                apps=("libreoffice-fresh" "onlyoffice-bin")
                ;;
            5)
                apps=("steam" "0ad" "supertuxkart")
                ;;
        esac
    done

    # Install the selected applications
    if [ -n "$apps" ]; then
        dialog --title "Installing Applications" --infobox "Installing selected applications..." 5 40
        sleep 2  # Simulate installation time
        sudo pacman -S --noconfirm "${apps[@]}"
        dialog --msgbox "Applications installed successfully!" 5 40
    else
        dialog --msgbox "No applications selected." 5 40
    fi
}

show_menu
install_apps



dialog --title "Installation Successful" --msgbox "You have successfully installed the OS.\n\nPlease unplug the USB drive and reboot your system." 10 50

closed
reboot