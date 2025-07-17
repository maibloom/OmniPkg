#!/usr/bin/env bash
set -euo pipefail

sudo pacman -Syu --noconfirm

sudo pacman -S cosmic --noconfirm

sudo pacman -S gdm --noconfirm
sudo systemctl enable gdm.service

sudo pacman -S packagekit power-profiles-daemon xdg-user-dirs gnome-keyring --noconfirm
sudo systemctl enable power-profiles-daemon.service
xdg-user-dirs-update

sudo pacman -S cosmic-text-editor cosmic-player --noconfirm
