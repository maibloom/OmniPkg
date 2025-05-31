#!/bin/bash
# uninstall_updatepro.sh - Uninstalls updatepro by removing the binary and systemd units.

set -e

echo "Uninstalling updatepro..."

# Stop and disable the systemd timer.
echo "Stopping and disabling updatepro.timer..."
sudo systemctl stop updatepro.timer || true
sudo systemctl disable updatepro.timer || true

# Stop the service in case it is running.
echo "Stopping updatepro.service..."
sudo systemctl stop updatepro.service || true

# Remove the systemd unit files.
echo "Removing systemd unit files..."
sudo rm -f /etc/systemd/system/updatepro.timer
sudo rm -f /etc/systemd/system/updatepro.service

# Remove the updatepro script from /usr/local/bin.
echo "Removing /usr/local/bin/updatepro..."
sudo rm -f /usr/local/bin/updatepro

# Reload systemd to reflect the changes
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "updatepro has been uninstalled successfully."
