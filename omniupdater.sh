#!/bin/bash

# Define variables
REPO_URL="https://github.com/devtracer/Omnipkg.git"
TEMP_DIR="/tmp/omnipkg_update"
INSTALL_DIR="/usr/local/bin"
INSTALL_SCRIPT="omnipkginstaller.sh"

# Create temporary directory for update
echo "Creating temporary directory for update..."
mkdir -p "$TEMP_DIR" || { echo "Failed to create temp directory. Exiting."; exit 1; }

# Navigate to the temp directory
cd "$TEMP_DIR" || { echo "Failed to access temp directory. Exiting."; exit 1; }

# Clone the repository
echo "Cloning Omnipkg repository..."
git clone "$REPO_URL" . || { echo "Failed to clone repository. Exiting."; exit 1; }

# Make the installer executable
chmod +x "./$INSTALL_SCRIPT" || { echo "Failed to set executable permissions. Exiting."; exit 1; }

# Run the installer
echo "Running the installer..."
./"$INSTALL_SCRIPT" || { echo "Installation failed. Exiting."; exit 1; }

# Confirm installation and remove old version
echo "Removing old omnipkg from $INSTALL_DIR..."
rm -f "$INSTALL_DIR/omnipkg" || { echo "Failed to remove old omnipkg. Exiting."; exit 1; }

# Move new omnipkg to the installation directory
echo "Installing new omnipkg to $INSTALL_DIR..."
mv omnipkg "$INSTALL_DIR/" || { echo "Failed to install new omnipkg. Exiting."; exit 1; }

# Clean up temporary files
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Omnipkg has been updated successfully!"
