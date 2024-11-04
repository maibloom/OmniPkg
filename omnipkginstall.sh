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

# Define package managers in an array
PACKAGES=("apt" "dnf" "rpm" "yast2" "zypper" "flatpak" "snapd" "nix" "docker" "pikaur" "paru")

# Generate dialog checklist options dynamically
options=()
for i in "${!PACKAGES[@]}"; do
    options+=($((i+1)) "${PACKAGES[$i]}" "off")
done

# Display dialog checklist
CHOICES=$(dialog --stdout --checklist "Select package managers to install:" 22 76 16 "${options[@]}")

# Exit if no choices were made
if [ -z "$CHOICES" ]; then
    dialog --msgbox "No package managers selected. Exiting." 6 40
    clear
    exit 1
fi

# Map selected choices to package names
selected_packages=()
for choice in $CHOICES; do
    selected_packages+=("${PACKAGES[$((choice-1))]}")
done

# Check if yay is installed before proceeding
if ! command -v yay &> /dev/null; then
    dialog --msgbox "The 'yay' package manager is required to install packages but is not installed. Please install yay first." 8 50
    clear
    exit 1
fi

# Install selected packages
if [ ${#selected_packages[@]} -gt 0 ]; then
    dialog --infobox "Installing selected packages..." 5 40
    sleep 2  # Pause to show the message
    yay -S --needed "${selected_packages[@]}" &>> "$LOG_FILE"
    dialog --msgbox "Installation complete." 6 30
else
    dialog --msgbox "No packages selected for installation." 6 40
fi

# Compile and move omnipkg binary (assuming omnipkg.c exists)
if [ -f omnipkg.c ]; then
    gcc -o omnipkg omnipkg.c
    chmod +x omnipkg
    sudo mv omnipkg /usr/local/bin/
    dialog --msgbox "omnipkg compiled and moved to /usr/local/bin/." 6 50
else
    dialog --msgbox "omnipkg.c source file not found. Skipping compilation." 6 50
fi

# Clear the dialog artifacts from the terminal
clear
