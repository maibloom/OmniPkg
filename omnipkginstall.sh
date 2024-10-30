#!/bin/bash

# Function to check if dialog is installed
check_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing it now..."
        sudo pacman -S --needed dialog
    fi
}

# Check for dialog
check_dialog

# Define package managers
PACKAGES=("apt" "dnf" "rpm" "yast2" "zypper" "flatpak" "snapd" "nix" "docker" "pikaur" "paru")

# Dialog checklist for package managers
CHOICES=$(dialog --stdout --checklist "Select package managers to install:" 22 76 16 \
1 "apt" off \
2 "dnf" off \
3 "rpm" off \
4 "yast2" off \
5 "zypper" off \
6 "flatpak" off \
7 "snapd" off \
8 "nix" off \
9 "docker" off \
10 "pikaur" off \
11 "paru" off \
)

# Exit if no choices were made
if [ -z "$CHOICES" ]; then
    dialog --msgbox "No package managers selected. Exiting." 6 40
    exit 1
fi

# Convert choices to an array
selected_packages=()
for choice in $CHOICES; do
    case $choice in
        1) selected_packages+=("apt") ;;
        2) selected_packages+=("dnf") ;;
        3) selected_packages+=("rpm") ;;
        4) selected_packages+=("yast2") ;;
        5) selected_packages+=("zypper") ;;
        6) selected_packages+=("flatpak") ;;
        7) selected_packages+=("snapd") ;;
        8) selected_packages+=("nix") ;;
        9) selected_packages+=("docker") ;;
        10) selected_packages+=("pikaur") ;;
        11) selected_packages+=("paru") ;;
    esac
done

# Install selected packages
if [ ${#selected_packages[@]} -gt 0 ]; then
    dialog --infobox "Installing selected packages..." 5 30
    sleep 2  # Pause to show the message
    yay -S --needed "${selected_packages[@]}"
    dialog --msgbox "Installation complete." 6 30
else
    dialog --msgbox "No packages selected for installation." 6 40
fi

gcc -o omnipkg omnipkg.c
