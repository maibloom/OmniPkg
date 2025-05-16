#!/bin/bash
set -euo pipefail

sudo rm -rf /usr/bin/google-bro-office

if [ -f /usr/share/applications/GoogleBroOffice.desktop ]; then
    sudo rm /usr/share/applications/GoogleBroOffice.desktop
    sudo update-desktop-database /usr/share/applications
fi

echo "Google Bro Office has been uninstalled system-wide."
