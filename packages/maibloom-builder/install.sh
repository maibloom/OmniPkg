#!/usr/bin/env bash
# This script clones, builds, and configures the Mai Bloom OS environment.

# Enable strict mode.
set -euo pipefail
IFS=$'\n\t'

# Trap errors and echo the failing command and line number.
trap 'echo "Error on line ${LINENO}: ${BASH_COMMAND}" >&2; exit 1' ERR

#######################
# Utility Functions
#######################

# Log an error message and exit.
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Change directory and exit if it fails.
change_directory() {
    local target_dir="$1"
    cd "$target_dir" || error_exit "Failed to change directory to '$target_dir'."
}

# Remove a directory if it exists.
remove_existing_directory() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        echo "Removing existing directory: $dir"
        sudo rm -rf "$dir"
    fi
}

# Prompt for sudo password upfront and keep the session alive.
initialize_sudo() {
    sudo -v
    # Keep-alive: update existing sudo time stamp until script finishes
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

#######################
# Process Functions
#######################

# Clone the repository from the provided URL.
clone_repository() {
    local repo_url="$1"
    git clone "$repo_url" || error_exit "Failed to clone repository: $repo_url"
}

# Run the build script with elevated privileges.
run_build_script() {
    local script="$1"
    sudo bash "$script" || error_exit "Build script '$script' failed."
}

# Update system packages.
update_system_packages() {
    sudo pacman -Syyu --noconfirm
}

# Install omnipkg packages.
install_omnipkg_packages() {
    omnipkg put install multilib-mirror pypippark google-bro-office tuxtalk welcometomaibloom
}

# Ensure that 'dialog' is installed.
install_dialog_if_needed() {
    if ! command -v dialog &> /dev/null; then
        echo "Installing 'dialog'..."
        sudo pacman -S dialog --noconfirm
    fi
}

# Configure fastfetch with custom settings.
configure_fastfetch() {
    local config_dir="/etc/fastfetch"
    local config_file="${config_dir}/config.conf"

    echo "Installing fastfetch..."
    sudo pacman -S --noconfirm fastfetch || { echo "Error: fastfetch installation failed."; return 1; }

    if [ ! -d "$config_dir" ]; then
        echo "Creating configuration directory: $config_dir"
        sudo mkdir -p "$config_dir" || { echo "Error: Could not create configuration directory."; return 1; }
    fi

    echo "Writing configuration to ${config_file}..."
    sudo tee "$config_file" > /dev/null << 'EOF'
print_info() {
    info "OS" "Mai Bloom OS"
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "Resolution" resolution
}
ascii_distro="mai bloom"
EOF

    echo "=> fastfetch configuration complete."
}

# Rename the operating system by modifying /etc/os-release.
rename_os() {
    local os_release_file="/etc/os-release"
    local backup_file="/etc/os-release.bak"

    echo "=> Renaming OS to 'Mai Bloom'..."

    # Backup the original file.
    sudo cp "$os_release_file" "$backup_file" || { echo "Error: Failed to backup os-release."; return 1; }

    # Use sed to modify specific fields.
    sudo sed -i 's/^NAME=.*/NAME="Mai Bloom OS"/' "$os_release_file"
    sudo sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Mai Bloom OS"/' "$os_release_file"
    sudo sed -i 's/^ID=.*/ID=mai_bloom/' "$os_release_file"
    sudo sed -i 's/^ID_LIKE=.*/ID_LIKE=arch/' "$os_release_file"
    sudo sed -i 's/^VERSION=.*/VERSION="1.0"/' "$os_release_file"
    sudo sed -i 's|^HOME_URL=.*|HOME_URL="https://maibloom.github.io"|' "$os_release_file"
    sudo sed -i 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/maibloom/maibloom.github.io/blob/d69c87b9fbcd907f9aa5d9e2ed294d8f84caee19/docs/menu.md"|' "$os_release_file"
    sudo sed -i 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/maibloom/maibloom.github.io/blob/d69c87b9fbcd907f9aa5d9e2ed294d8f84caee19/docs/menu.md"|' "$os_release_file"
    sudo sed -i 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/maibloom/iso/issues"|' "$os_release_file"
    sudo sed -i 's/^ANSI_COLOR=.*/ANSI_COLOR="0;36"/' "$os_release_file"

    echo "=> OS renamed successfully."
}

# Show a success message using dialog and prompt for reboot.
show_success_message_and_reboot() {
    dialog --title "Installation Successful" --msgbox "You have successfully installed the OS.\n\nPlease unplug the USB drive and reboot your system." 10 50
    # Optionally, uncomment the following line to reboot automatically:
    # sudo reboot
}

#######################
# Main Script Execution
#######################

main() {
    # Initialize sudo session.
    initialize_sudo

    # Navigate to the temporary directory.
    change_directory "/tmp"

    # Remove any leftover repository directory.
    remove_existing_directory "omnipkg-app"

    # Clone the repository.
    clone_repository "https://www.github.com/maibloom/omnipkg-app"

    # Change into the newly cloned repository.
    change_directory "omnipkg-app"

    # Run the build script.
    run_build_script "build.sh"

    # Update system packages.
    update_system_packages

    echo "Build succeeded."

    # Install omnipkg packages.
    install_omnipkg_packages

    # Ensure 'dialog' is installed.
    install_dialog_if_needed


    # Configure additional software.
    configure_fastfetch
    rename_os

    # Final message and reboot.
    show_success_message_and_reboot
}

# Run the main function.
main
