#!/bin/bash

post_build() {
  cd /tmp/ || exit 1

  # Remove existing directory if it exists
  [ -d "omnipkg-app" ] && sudo rm -rf omnipkg-app/

  # Clone the repository
  if ! git clone https://www.github.com/maibloom/omnipkg-app; then
    echo "Failed to clone repository."
    exit 1
  fi

  cd omnipkg-app/ || exit 1

  # Run the build script
  if sudo bash build.sh; then
    # Update system packages
    sudo pacman -Syyu --noconfirm

    echo "Build succeeded."

    # Install omnipkg packages
    omnipkg put install google-bro-office tuxtalk

    # Ensure 'dialog' is installed
    if ! command -v dialog &> /dev/null; then
      sudo pacman -S dialog --noconfirm
    fi

    # Define the options for the checklist
    OPTIONS=(
      1 "Education" OFF
      2 "Programming" OFF
      3 "Office" OFF
      4 "Daily Use" OFF
      5 "Gaming" OFF
    )

    # Create the checklist dialog
    CHOICES=$(dialog --clear --title "Let's optimise your experience..." \
      --checklist "Which of the following are you going to use your device for?" 15 50 5 \
      "${OPTIONS[@]}" \
      3>&1 1>&2 2>&3)

    clear

    # Handle the user's selections
    if [[ -z "$CHOICES" ]]; then
      echo "No option selected."
    else
      for CHOICE in $CHOICES; do
        case $CHOICE in
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
            echo "Invalid option: $CHOICE"
            ;;
        esac
      done
    fi

    # Configure Neofetch
    sudo tee /etc/neofetch/config.conf > /dev/null << 'EOF'
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

    # Rename OS
    echo "=> Renaming OS to 'Mai Bloom'..."
    sudo tee /etc/os-release > /dev/null << 'EOF'
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

    # Display success message
    dialog --title "Installation Successful" --msgbox "You have successfully installed the OS.\n\nPlease unplug the USB drive and reboot your system." 10 50

    # Reboot the system
    reboot
  else
    echo "Running build has failed."
  fi
}

archinstall

post_build
