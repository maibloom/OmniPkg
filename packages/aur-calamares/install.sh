#!/bin/bash

set -eo pipefail

if ! command -v git &> /dev/null; then
    echo "git is not installed. Please install it first."
    echo "On Arch Linux: sudo pacman -S git"
    exit 1
fi

if ! command -v makepkg &> /dev/null; then
    echo "makepkg is not installed. Please install the 'base-devel' group."
    echo "On Arch Linux: sudo pacman -S base-devel --needed"
    exit 1
fi

GIT_REPO_URL="https://github.com/BioArchLinux/Packages.git"
REPO_LOCAL_NAME="BioArchLinux_Packages_src"
PACKAGE_SUBDIR="BioArchLinux/calamares"
BUILT_PACKAGE_FILE=""

cleanup() {
    echo "Cleaning up cloned repository: $REPO_LOCAL_NAME"
    if [ -d "$REPO_LOCAL_NAME" ]; then
        rm -rf "$REPO_LOCAL_NAME"
    fi
}

trap cleanup EXIT ERR

echo "Cloning repository $GIT_REPO_URL..."
if [ -d "$REPO_LOCAL_NAME" ]; then
    echo "Repository directory $REPO_LOCAL_NAME already exists. Removing it."
    rm -rf "$REPO_LOCAL_NAME"
fi
git clone "$GIT_REPO_URL" "$REPO_LOCAL_NAME"

cd "$REPO_LOCAL_NAME/$PACKAGE_SUBDIR"

echo "Building package in $(pwd)..."
echo "makepkg will ask for your sudo password to install build dependencies if needed."
makepkg -s --noconfirm

BUILT_PACKAGE_FILE=$(makepkg --packagelist)
if [ -z "$BUILT_PACKAGE_FILE" ] || [ ! -f "$BUILT_PACKAGE_FILE" ]; then
    echo "Could not find built package file. Exiting."
    exit 1
fi

echo "Installing built package: $BUILT_PACKAGE_FILE..."
sudo pacman -U --noconfirm "$BUILT_PACKAGE_FILE"

echo "Calamares should now be installed from the BioArchLinux PKGBUILD."
echo "You can try launching it from your GUI menu or by typing 'calamares' in the terminal."

cd ../../..

exit 0

