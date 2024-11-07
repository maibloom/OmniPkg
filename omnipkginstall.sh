#!/bin/bash

# Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
    echo "This script requires root privileges. Please run it as root or with sudo."
    exit 1
fi

# Define the installation path
INSTALL_PATH="/usr/local/bin/omnipkg"

echo "Installing Omnipkg to $INSTALL_PATH..."
# Move the omnipkg script and version file to the installation path
if mv omnipkg "$INSTALL_PATH" && mv version.txt "$INSTALL_PATH/version.txt"; then
    chmod +x "$INSTALL_PATH"
    echo "Omnipkg installed successfully and is now executable."
else
    echo "Installation failed. Could not move Omnipkg to $INSTALL_PATH."
    exit 1
fi
