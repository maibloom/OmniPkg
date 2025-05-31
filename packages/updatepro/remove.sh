#!/bin/bash
# uninstall_updatepro.sh - Uninstalls updatepro by removing the binary, systemd units,
# and optionally its configuration file.
#
# Usage:
#   ./uninstall_updatepro.sh         # Removes updatepro but leaves the config file intact.
#   ./uninstall_updatepro.sh --purge   # Also removes the configuration file /etc/updatepro.conf.

set -e

echo "Uninstalling updatepro..."

# Stop and disable the systemd timer.
echo "Stopping and disabling updatepro.timer..."
sudo systemctl stop updatepro.timer || true
sudo systemctl disable updatepro.timer || true

# Stop the service, if it is running.
echo "Stopping updatepro.service..."
sudo systemctl stop updatepro.service || true

# Remove the systemd unit files.
echo "Removing systemd unit files..."
sudo rm -f /etc/systemd/system/updatepro.timer
sudo rm -f /etc/systemd/system/updatepro.service

# Remove the updatepro script from /usr/local/bin.
echo "Removing /usr/local/bin/updatepro..."
sudo rm -f /usr/local/bin/updatepro

# Optionally remove the configuration file.
if [ "$1" == "--purge" ]; then
    if [ -f /etc/updatepro.conf ]; then
        echo "Purging configuration file /etc/updatepro.conf..."
        sudo rm -f /etc/updatepro.conf
    else
        echo "No configuration file found at /etc/updatepro.conf."
    fi
fi

# Reload the systemd daemon to reflect the changes.
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "updatepro has been uninstalled successfully."
