#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
CALAMARES_VERSION="3.3.14" # Specify the Calamares version you want to build
# You can find the latest releases at: https://github.com/calamares/calamares/releases
# --- End Configuration ---

CALAMARES_TARBALL="calamares-${CALAMARES_VERSION}.tar.gz"
CALAMARES_SOURCE_DIR="calamares-${CALAMARES_VERSION}"
DOWNLOAD_URL="https://github.com/calamares/calamares/releases/download/v${CALAMARES_VERSION}/${CALAMARES_TARBALL}"

echo "INFO: This script will download, build, and install Calamares ${CALAMARES_VERSION} globally."
echo "INFO: It assumes you are running on Arch Linux in a live GUI environment"
echo "INFO: as a user with root privileges (either root directly or with sudo access)."
echo "INFO: An internet connection is required."
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."
echo ""

# Determine if sudo is needed
if [[ $EUID -ne 0 ]]; then
    SUDO_CMD="sudo"
else
    SUDO_CMD=""
fi

echo ">>> Step 1: Updating package database and installing dependencies..."
${SUDO_CMD} pacman -Syu --needed --noconfirm \
    base-devel cmake extra-cmake-modules \
    qt5-base qt5-svg qt5-tools \
    kcoreaddons ki18n kparts ksolid kwidgetsaddons kcrash \
    yaml-cpp polkit-qt5 kpmcore icu boost-libs \
    python python-yaml python-polib \
    hwinfo squashfs-tools gettext dosfstools efibootmgr parted wget \
    kiconthemes # Often good for a better UI experience

# Create a temporary build directory
# Uses XDG_RUNTIME_DIR if available (like /run/user/1000), otherwise /tmp
BUILD_PARENT_DIR=$(mktemp -d -p "${XDG_RUNTIME_DIR:-/tmp}" calamares_build_XXXXXX)
echo "INFO: Using temporary build directory: ${BUILD_PARENT_DIR}"
cd "${BUILD_PARENT_DIR}"

echo ""
echo ">>> Step 2: Downloading Calamares ${CALAMARES_VERSION} source..."
wget --progress=bar:force -O "${CALAMARES_TARBALL}" "${DOWNLOAD_URL}"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to download Calamares tarball."
    echo "Please check the URL, version (${CALAMARES_VERSION}), and your internet connection."
    rm -rf "${BUILD_PARENT_DIR}" # Clean up
    exit 1
fi

echo ""
echo ">>> Step 3: Extracting Calamares source..."
tar -xzf "${CALAMARES_TARBALL}"
cd "${CALAMARES_SOURCE_DIR}"

echo ""
echo ">>> Step 4: Configuring the build (CMake)..."
mkdir -p build
cd build

# CMAKE_INSTALL_PREFIX:
#   /usr/local: Standard for manually compiled software, keeps it separate from pacman.
#               Usually in PATH. This is the recommended default.
#   /usr:       Installs into the system's main directories (like pacman packages).
#               Use if you specifically need Calamares in /usr/bin, but be aware
#               pacman won't manage these files.
CMAKE_INSTALL_PREFIX="/usr/local"

cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
         -DENABLE_TESTS=OFF # Disable tests to speed up build; not needed for just running

echo ""
echo ">>> Step 5: Compiling Calamares (make)..."
# Use $(nproc) to get the number of processing units available to speed up compilation
make -j$(nproc)

echo ""
echo ">>> Step 6: Installing Calamares globally (${SUDO_CMD} make install)..."
# This step MUST be run with root privileges for global installation
${SUDO_CMD} make install

echo ""
echo ">>> Step 7: Verifying installation..."
INSTALLED_PATH=$(${SUDO_CMD} which calamares) # Use sudo if needed for which in case of restricted PATH for normal user

if [[ -n "${INSTALLED_PATH}" && -x "${INSTALLED_PATH}" ]]; then
    echo "SUCCESS: Calamares installed!"
    echo "Executable found at: ${INSTALLED_PATH}"
    echo "You can now try running: ${SUDO_CMD} calamares"
else
    echo "WARNING: Calamares executable not found in the default PATH immediately after installation."
    echo "It was likely installed to '${CMAKE_INSTALL_PREFIX}/bin/calamares'."
    if [[ ":$PATH:" != *":${CMAKE_INSTALL_PREFIX}/bin:"* ]]; then
        echo "Your current PATH might not include '${CMAKE_INSTALL_PREFIX}/bin'."
        echo "You can try running it directly: ${SUDO_CMD} ${CMAKE_INSTALL_PREFIX}/bin/calamares"
        echo "To add it to your PATH for this session: export PATH=\$PATH:${CMAKE_INSTALL_PREFIX}/bin"
    else
         echo "Try running: ${SUDO_CMD} $(basename ${INSTALLED_PATH:-${CMAKE_INSTALL_PREFIX}/bin/calamares})"
    fi
fi

echo ""
echo ">>> Step 8: Cleaning up temporary build files..."
cd / # Go to a safe directory before removing the build parent
echo "INFO: Removing temporary build directory: ${BUILD_PARENT_DIR}"
rm -rf "${BUILD_PARENT_DIR}"

echo ""
echo "Installation process finished."
echo "Remember that Calamares performs system-level operations and usually requires root privileges to run."
echo "Try: ${SUDO_CMD} $(which calamares || echo ${CMAKE_INSTALL_PREFIX}/bin/calamares)"

