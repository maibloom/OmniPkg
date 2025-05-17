#!/bin/bash

sudo pacman -Syyu

echo "success"

omnipkg put install google-bro-office tuxtalk

sudo pacman -S dialog --noconfirm

# Define the options for the checklist
OPTIONS=(1 "Education" OFF
         2 "Programming" OFF
         3 "Office" OFF
         4 "Daily Use" OFF
	     5 "Gaming" OFF
         )

# Create the checklist dialog
CHOICES=$(dialog --clear --title "Let's optimise your experience..." \
                 --checklist "Which of the following are you going to use your device for?" 15 50 5 \
                 "${OPTIONS[@]}" \
                 3>&1 1>&2 2>&3)

clear

# Handle the user's selections
if [[ -z "$CHOICES" ]]; then
    echo "No option selected."
else
    for CHOICE in $CHOICES; do
        case $CHOICE in
            1) sudo pacman -Syu gcompris-qt kbruch kgeography kalzium stellarium geogebra tuxmath wxmaxima libreoffice-fresh firefox chromium okular evince --noconfirm ;;
            2) sudo pacman -Syu base-devel neovim vim code geany kate kwrite clang python nodejs npm jdk-openjdk go rustup cmake ninja maven gradle docker qemu-desktop libvirt virt-manager dnsmasq edk2-ovmf alacritty konsole gnome-terminal gdb valgrind zeal tilix kitty --noconfirm ;;
            3) sudo pacman -Syu libreoffice-fresh onlyoffice-desktopeditors okular evince zim --noconfirm ;;
            4) sudo pacman -Syu firefox chromium thunderbird evolution kontact vlc mpv cantata elisa clementine gwenview eog loupe gimp inkscape krita darktable rawtherapee dolphin nautilus thunar pcmanfm pidgin telegram-desktop discord keepassxc flameshot ksnip calibre kdeconnect bleachbit alacritty konsole gnome-terminal tilix kitty --noconfirm ;;
            5) sudo pacman -Syu steam lutris heroic-games-launcher wine wine-mono wine-gecko retroarch dolphin-emu pcsx2 mangohud lib32-mangohud gamemode lib32-gamemode corectrl gwe discord mumble vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel --noconfirm ;;
	    *) echo "Invalid option" ;;
        esac
    done
fi




dialog --title "Installation Successful" --msgbox "You have successfully installed the OS.\n\nPlease unplug the USB drive and reboot your system." 10 50

reboot
