#!/bin/bash
set -e

# --- Configuration ---
CALAMARES_VERSION="3.3.14" # Target Calamares version
# Latest releases: https://github.com/calamares/calamares/releases
# --- End Configuration ---

CALAMARES_TARBALL="calamares-${CALAMARES_VERSION}.tar.gz"
CALAMARES_SOURCE_DIR="calamares-${CALAMARES_VERSION}"
DOWNLOAD_URL="https://github.com/calamares/calamares/releases/download/v${CALAMARES_VERSION}/${CALAMARES_TARBALL}"

echo "INFO: Building Calamares ${CALAMARES_VERSION} on Arch Linux (requires root/sudo and internet)."
echo ""

if [[ $EUID -ne 0 ]]; then
    SUDO_CMD="sudo"
else
    SUDO_CMD=""
fi

echo ">>> Step 1: Updating package database and installing dependencies..."
${SUDO_CMD} pacman -Syu --needed --noconfirm \
    base-devel cmake extra-cmake-modules \
    qt5-base qt5-svg qt5-tools \
    kcoreaddons ki18n kparts solid kwidgetsaddons kcrash \
    yaml-cpp polkit-qt5 kpmcore icu boost-libs \
    python python-yaml python-polib \
    hwinfo squashfs-tools gettext dosfstools efibootmgr parted wget \
    kiconthemes # For a better UI experience

# Uses XDG_RUNTIME_DIR if available (e.g., /run/user/UID), otherwise /tmp
BUILD_PARENT_DIR=$(mktemp -d -p "${XDG_RUNTIME_DIR:-/tmp}" calamares_build_XXXXXX)
echo "INFO: Using temporary build directory: ${BUILD_PARENT_DIR}"
cd "${BUILD_PARENT_DIR}"

echo ""
echo ">>> Step 2: Downloading Calamares ${CALAMARES_VERSION} source..."
wget --progress=bar:force -O "${CALAMARES_TARBALL}" "${DOWNLOAD_URL}"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to download Calamares tarball. Check version and internet."
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
#   /usr/local: Standard for manually compiled software (recommended default).
#   /usr:       To install into system's main directories (like pacman packages).
CMAKE_INSTALL_PREFIX="/usr/local"

cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
         -DENABLE_TESTS=OFF # Disable tests to speed up build

echo ""
echo ">>> Step 5: Compiling Calamares (make)..."
make -j$(nproc)

echo ""
echo ">>> Step 6: Installing Calamares globally (${SUDO_CMD} make install)..."
${SUDO_CMD} make install

echo ""
echo ">>> Step 7: Verifying installation..."
INSTALLED_PATH=""
if [[ -x "${CMAKE_INSTALL_PREFIX}/bin/calamares" ]]; then
    INSTALLED_PATH="${CMAKE_INSTALL_PREFIX}/bin/calamares"
else # Fallback to 'which' if CMAKE_INSTALL_PREFIX was changed or for some other reason
    if [[ $EUID -ne 0 ]]; then
        INSTALLED_PATH=$(${SUDO_CMD} which calamares 2>/dev/null)
    else
        INSTALLED_PATH=$(which calamares 2>/dev/null)
    fi
fi

if [[ -n "${INSTALLED_PATH}" && -x "${INSTALLED_PATH}" ]]; then
    echo "SUCCESS: Calamares installed!"
    echo "Executable found at: ${INSTALLED_PATH}"
    echo "You can now try running: ${SUDO_CMD} $(basename ${INSTALLED_PATH})"
else
    echo "WARNING: Calamares executable not found in PATH or expected location (${CMAKE_INSTALL_PREFIX}/bin/calamares)."
    if [[ ":$PATH:" != *":${CMAKE_INSTALL_PREFIX}/bin:"* && $EUID -ne 0 ]]; then
        echo "Your current PATH might not include '${CMAKE_INSTALL_PREFIX}/bin'."
        echo "Try: ${SUDO_CMD} ${CMAKE_INSTALL_PREFIX}/bin/calamares or add to PATH: export PATH=\$PATH:${CMAKE_INSTALL_PREFIX}/bin"
    else
         echo "Try running: ${SUDO_CMD} ${CMAKE_INSTALL_PREFIX}/bin/calamares"
    fi
fi

echo ""
echo ">>> Step 8: Cleaning up temporary build files..."
cd / # Go to a safe directory before removing the build parent
echo "INFO: Removing temporary build directory: ${BUILD_PARENT_DIR}"
rm -rf "${BUILD_PARENT_DIR}"

echo ""
echo "Installation process finished."
echo "Calamares usually requires root privileges to run (e.g., for disk partitioning)."

FINAL_RUN_CMD="${CMAKE_INSTALL_PREFIX}/bin/calamares"
if [[ -n "${INSTALLED_PATH}" && -x "${INSTALLED_PATH}" ]]; then
    FINAL_RUN_CMD="${INSTALLED_PATH}"
fi
echo "Try: ${SUDO_CMD} ${FINAL_RUN_CMD}"

