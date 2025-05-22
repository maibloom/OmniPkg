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

#######################
# Process Functions
#######################

# Clone the repository from the provided URL.
clone_repository() {
  local repo_url="$1"
  if ! git clone "$repo_url"; then
    error_exit "Failed to clone repository: $repo_url"
  fi
}

# Run the build script with elevated privileges.
run_build_script() {
  local script="$1"
  if ! sudo bash "$script"; then
    error_exit "Build script '$script' failed."
  fi
}

# Update system packages.
update_system_packages() {
  sudo pacman -Syyu --noconfirm
}

# Install omnipkg packages.
install_omnipkg_packages() {
  omnipkg put install google-bro-office tuxtalk
}

# Ensure that 'dialog' is installed.
install_dialog_if_needed() {
  if ! command -v dialog &> /dev/null; then
    echo "Installing 'dialog'..."
    sudo pacman -S dialog --noconfirm
  fi
}

# Display a checklist dialog to the user and return their selections.
display_checklist() {
  local title="Let's optimise your experience..."
  local prompt="Which of the following are you going to use your device for?"
  local height=15 width=50 list_height=5
  local options=(
    1 "Education" OFF
    2 "Programming" OFF
    3 "Office" OFF
    4 "Daily Use" OFF
    5 "Gaming" OFF
  )

  # Capture the user's choices.
  CHOICES=$(dialog --clear --title "$title" \
    --checklist "$prompt" "$height" "$width" "$list_height" \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  clear

  echo "$CHOICES"
}

# Handle the selected options with specific package installations.
handle_selections() {
  local choices="$1"

  if [[ -z "$choices" ]]; then
    echo "No option selected."
    return
  fi

  for choice in $choices; do
    case "$choice" in
      1)
        sudo pacman -Syu gcompris-qt kbruch kgeography kalzium geogebra libreoffice-fresh firefox chromium okular evince --noconfirm
        ;;
      2)
        sudo pacman -Syu base-devel neovim vim code geany kate kwrite clang python nodejs npm jdk-openjdk go rustup cmake ninja maven gradle docker qemu-desktop libvirt virt-manager dnsmasq edk2-ovmf alacritty konsole gnome-terminal gdb valgrind zeal tilix kitty --noconfirm
        ;;
      3)
        sudo pacman -Syu libreoffice-fresh okular evince zim --noconfirm
        ;;
      4)
        sudo pacman -Syu firefox chromium thunderbird evolution kontact vlc mpv elisa gwenview eog loupe gimp inkscape krita darktable rawtherapee dolphin nautilus thunar pcmanfm pidgin telegram-desktop discord keepassxc flameshot ksnip calibre kdeconnect bleachbit alacritty konsole gnome-terminal tilix kitty --noconfirm
        ;;
      5)
        sudo pacman -Syu gamescope sl lutris wine wine-mono wine-gecko retroarch dolphin-emu pcsx2 mangohud lib32-mangohud gamemode lib32-gamemode corectrl gwe discord mumble vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel --noconfirm
        ;;
      *)
        echo "Invalid option: $choice"
        ;;
    esac
  done
}

# Configure Neofetch with custom settings.
configure_neofetch() {
  local config_file="/etc/neofetch/config.conf"
  echo "Configuring Neofetch..."
  sudo tee "$config_file" > /dev/null << 'EOF'
# Mai Bloom Custom Neofetch Configuration
#
# This function customizes the default system information output.
print_info() {
    info "OS" "Mai Bloom"
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "Resolution" resolution
}

# Define the ASCII logo text for Mai Bloom.
ascii_distro="mai bloom"
EOF
  echo "=> Neofetch configuration complete."
}

# Rename the operating system by modifying /etc/os-release.
rename_os() {
  local os_release_file="/etc/os-release"
  echo "=> Renaming OS to 'Mai Bloom'..."
  sudo tee "$os_release_file" > /dev/null << 'EOF'
NAME="Mai Bloom"
VERSION="1.0"
ID=mai_bloom
ID_LIKE=arch
PRETTY_NAME="Mai Bloom"
ANSI_COLOR="0;36"
HOME_URL="https://maibloom.github.io"
DOCUMENTATION_URL="https://github.com/maibloom/maibloom.github.io/blob/d69c87b9fbcd907f9aa5d9e2ed294d8f84caee19/docs/menu.md"
SUPPORT_URL="https://github.com/maibloom/maibloom.github.io/blob/d69c87b9fbcd907f9aa5d9e2ed294d8f84caee19/docs/menu.md"
BUG_REPORT_URL="https://github.com/maibloom/iso/issues"
EOF
}

# Show a success message using dialog and reboot the system.
show_success_message_and_reboot() {
  dialog --title "Installation Successful" --msgbox "You have successfully installed the OS.\n\nPlease unplug the USB drive and reboot your system." 10 50
  echo "Rebooting system..."
  sudo reboot
}

#######################
# Main Script Execution
#######################

main() {
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
  
  # Display checklist dialog and handle selections.
  local selections
  selections=$(display_checklist)
  handle_selections "$selections"
  
  # Configure additional software.
  configure_neofetch
  rename_os
  
  # Final message and reboot.
  show_success_message_and_reboot
}

# Run the main function.
main
