#!/bin/bash

set -eo pipefail

if ! command -v svn &> /dev/null; then
    echo "svn (subversion) is not installed. Please install it first."
    echo "On Arch Linux: sudo pacman -S subversion"
    exit 1
fi

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

GITHUB_REPO_PATH="BioArchLinux/Packages"
PACKAGE_SUBDIR="BioArchLinux/calamares"
# For GitHub, trunk usually points to the default branch (e.g., master or main)
# The URL was https://github.com/BioArchLinux/Packages/tree/master/BioArchLinux/calamares
# So, we use /trunk/ which maps to the default branch path.
SVN_EXPORT_URL="https://github.com/${GITHUB_REPO_PATH}/tree/master/${PACKAGE_SUBDIR}"

# Local directory name for the downloaded PKGBUILD files
LOCAL_PKG_DIR="calamares_pkgbuild_dir"
BUILT_PACKAGE_FILE=""

cleanup() {
    echo "Cleaning up downloaded PKGBUILD directory: $LOCAL_PKG_DIR"
    if [ -d "$LOCAL_PKG_DIR" ]; then
        rm -rf "$LOCAL_PKG_DIR"
    fi
}

trap cleanup EXIT ERR

echo "Exporting $PACKAGE_SUBDIR from GitHub repository using svn..."
if [ -d "$LOCAL_PKG_DIR" ]; then
    echo "Directory $LOCAL_PKG_DIR already exists. Removing it."
    rm -rf "$LOCAL_PKG_DIR"
fi

# svn export URL TARGET_DIR
svn export --force "$SVN_EXPORT_URL" "$LOCAL_PKG_DIR"

cd "$LOCAL_PKG_DIR"

echo "Building package in $(pwd)..."
echo "makepkg will ask for your sudo password to install build dependencies if needed."
makepkg -s --noconfirm

BUILT_PACKAGE_FILE=$(makepkg --packagelist)
if [ -z "$BUILT_PACKAGE_FILE" ] || [ ! -f "$BUILT_PACKAGE_FILE" ]; then
    echo "Could not find built package file. Exiting."
    # Attempt to find it with a glob as a fallback, though --packagelist is preferred
    shopt -s nullglob
    PKG_FILES=(*.pkg.tar.zst *.pkg.tar.xz *.pkg.tar.gz)
    shopt -u nullglob
    if [ ${#PKG_FILES[@]} -eq 1 ]; then
        BUILT_PACKAGE_FILE="${PKG_FILES[0]}"
        echo "Found package file via glob: $BUILT_PACKAGE_FILE"
    else
        echo "Still could not reliably determine built package file. Exiting."
        exit 1
    fi
fi


echo "Installing built package: $BUILT_PACKAGE_FILE..."
sudo pacman -U --noconfirm "$BUILT_PACKAGE_FILE"

echo "Calamares should now be installed using the PKGBUILD from $SVN_EXPORT_URL."
echo "You can try launching it from your GUI menu or by typing 'calamares' in the terminal."

cd ..

exit 0

