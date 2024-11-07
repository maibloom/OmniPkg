#!/bin/bash

# Function to check for root privileges
function check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script requires root privileges. Please run it as root or with sudo."
        exit 1
    fi
}

# Function to perform an upgrade if a newer version exists
function upgrade() {
    TEMP_DIR=$(mktemp -d)
    CURRENT_VER=$(cat /usr/local/bin/omnipkg/version.txt)

    # Fetch the latest version number from GitHub
    wget -qO "$TEMP_DIR/version.txt" https://raw.githubusercontent.com/devtracer/Omnipkg/main/version.txt
    if [[ $? -ne 0 ]]; then
        echo "Failed to fetch the latest version info. Please check your internet connection."
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    LATEST_VER=$(cat "$TEMP_DIR/version.txt")
    if [[ "$CURRENT_VER" != "$LATEST_VER" ]]; then
        echo "New version detected. Upgrading Omnipkg to version $LATEST_VER..."
        
        # Download the updated omnipkg from the raw GitHub URL
        wget -qO "$TEMP_DIR/omnipkg" https://raw.githubusercontent.com/devtracer/Omnipkg/main/omnipkg
        if [[ $? -ne 0 ]]; then
            echo "Failed to download the latest Omnipkg script. Exiting."
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        # Replace the old Omnipkg
        chmod +x "$TEMP_DIR/omnipkg"
        mv "$TEMP_DIR/omnipkg" /usr/local/bin/omnipkg
        echo "Omnipkg has been updated to version $LATEST_VER."
    else
        echo "You're using the latest version of Omnipkg."
    fi

    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Check for root privileges before upgrading
check_root
upgrade
