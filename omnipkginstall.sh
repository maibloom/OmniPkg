#!/bin/bash

# Log function with timestamp
LOG_FILE="/var/log/arch_install.log"
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if dialog and yay are installed
check_dependencies() {
    if ! command -v dialog &> /dev/null; then
        echo "dialog is not installed. Installing it now..."
        sudo pacman -S --needed dialog
    fi

    if ! command -v yay &> /dev/null; then
        dialog --msgbox "The 'yay' package manager is required to install packages but is not installed. Please install yay first." 8 50
        clear
        exit 1
    fi
}

# Check for necessary tools
check_dependencies

# Define the list of package managers to install
PACKAGES=("apt" "dnf" "rpm" "yast2" "zypper" "flatpak" "snapd" "nix" "docker" "pikaur" "paru")

# Inform the user and start installation
dialog --msgbox "Installing all predefined package managers. This may take some time." 8 50
log "Starting installation of all package managers..."

# Install each package
for package in "${PACKAGES[@]}"; do
    log "Installing $package..."
    yay -S --needed "$package" &>> "$LOG_FILE"
    if [ $? -ne 0 ]; then
        log "Failed to install $package."
    else
        log "$package installed successfully."
    fi
done

# Final message after installation
dialog --msgbox "All package installations complete." 6 40

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
