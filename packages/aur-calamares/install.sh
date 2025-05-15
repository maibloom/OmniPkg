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

AUR_PACKAGE_NAME="calamares"
BUILD_DIR="${AUR_PACKAGE_NAME}_aur_build"

cleanup() {
    if [ -d "$BUILD_DIR" ]; then
        echo "Cleaning up build directory: $BUILD_DIR"
        rm -rf "$BUILD_DIR"
    fi
}

trap cleanup EXIT ERR

echo "Cloning AUR repository for $AUR_PACKAGE_NAME..."
if [ -d "$BUILD_DIR" ]; then
    echo "Build directory $BUILD_DIR already exists. Removing it."
    rm -rf "$BUILD_DIR"
fi
git clone "https://aur.archlinux.org/${AUR_PACKAGE_NAME}.git" "$BUILD_DIR"

cd "$BUILD_DIR"

echo "Building and installing $AUR_PACKAGE_NAME..."
echo "makepkg will ask for your sudo password to install dependencies and the final package."
makepkg -si

echo "$AUR_PACKAGE_NAME should now be installed."
echo "You can try launching it from your GUI menu or by typing 'calamares' in the terminal."
echo "If 'calamares' command is not found immediately, you might need to open a new terminal session."

cd ..

exit 0

