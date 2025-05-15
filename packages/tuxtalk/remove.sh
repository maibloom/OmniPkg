#!/bin/bash
set -euo pipefail

sudo rm -rf /usr/bin/TuxTalk

if [ -f /usr/share/applications/TuxTalk.desktop ]; then
    sudo rm /usr/share/applications/TuxTalk.desktop
    sudo update-desktop-database /usr/share/applications
fi

echo "TuxTalk has been uninstalled system-wide."
