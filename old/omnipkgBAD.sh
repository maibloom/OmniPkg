#!/bin/bash

set -e  # Exit on error

# Constants
LOG_FILE="/var/log/package_manager.log"

# Functions
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Please run as root or with sudo."
        exit 1
    fi
}

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - [$level] - $message" | tee -a "$LOG_FILE"
}

check_internet() {
    log "INFO" "Checking internet connectivity..."
    if ! ping -q -c 1 -W 1 8.8.8.8 &> /dev/null; then
        log "ERROR" "No internet connection detected. Please check your network and try again."
        exit 1
    fi
    log "INFO" "Internet connection is active."
}

install_aur_helper() {
    local helper="$1"

    if command -v "$helper" &> /dev/null; then
        log "INFO" "$helper is already installed."
        return 0
    fi

    log "INFO" "$helper not found. Attempting to install using pacman..."
    case "$helper" in
        yay)
            pacman -S --noconfirm --needed yay || log "ERROR" "Failed to install $helper. Install it manually."
            ;;
        paru)
            pacman -S --noconfirm --needed paru || log "ERROR" "Failed to install $helper. Install it manually."
            ;;
        trizen)
            pacman -S --noconfirm --needed trizen || log "ERROR" "Failed to install $helper. Install it manually."
            ;;
        pikaur)
            pacman -S --noconfirm --needed pikaur || log "ERROR" "Failed to install $helper. Install it manually."
            ;;
        *)
            log "ERROR" "Unknown AUR helper: $helper. Cannot install."
            ;;
    esac
}

check_and_install_aur_helpers() {
    local helpers=("yay" "paru" "trizen" "pikaur")
    for helper in "${helpers[@]}"; do
        install_aur_helper "$helper"
    done
}

# Package manager commands
declare -A PM_COMMANDS=(
    ["pacman_list"]="pacman -Qq"
    ["yay_list"]="yay -Qq"
    ["paru_list"]="paru -Qq"
    ["trizen_list"]="trizen -Qq"
    ["pikaur_list"]="pikaur -Qq"
)

declare -A INSTALL_COMMANDS=(
    ["pacman"]="pacman -S --noconfirm"
    ["yay"]="yay -S --noconfirm"
    ["paru"]="paru -S --noconfirm"
    ["trizen"]="trizen -S --noconfirm"
    ["pikaur"]="pikaur -S --noconfirm"
)

detect_managers() {
    local available_managers=()
    for manager in "${!PM_COMMANDS[@]}"; do
        if command -v "${manager/_list/}" &> /dev/null; then
            available_managers+=("${manager/_list/}")
        fi
    done
    echo "${available_managers[@]}"
}

install_package() {
    local package="$1"
    log "INFO" "Installing $package..."
    for manager in $(detect_managers); do
        if run_command "${INSTALL_COMMANDS["${manager}"]} $package"; then
            log "INFO" "$package installed with $manager."
            return
        fi
    done
    log "ERROR" "Failed to install $package with any package manager."
    exit 1
}

update_packages() {
    log "INFO" "Updating all packages..."
    for manager in $(detect_managers); do
        case "$manager" in
            pacman) run_command "pacman -Syu --noconfirm" ;;
            yay) run_command "yay -Syu --noconfirm" ;;
            paru) run_command "paru -Syu --noconfirm" ;;
            trizen) run_command "trizen -Syu --noconfirm" ;;
            pikaur) run_command "pikaur -Syu --noconfirm" ;;
        esac
    done
    log "INFO" "All packages updated."
}

show_help() {
    echo "Usage: $0 {install|update|help} [args...]"
    echo
    echo "Commands:"
    echo "  install <packages...>         Install specified packages"
    echo "  update                        Update all installed packages"
    echo "  help                          Show this help message"
}

run_command() {
    local command="$1"
    if eval "$command"; then
        log "INFO" "Successfully executed: $command"
    else
        log "ERROR" "Error executing: $command"
        exit 1
    fi
}

# Main script logic
check_root
check_internet
check_and_install_aur_helpers

case "$1" in
    install)
        shift
        for package in "$@"; do
            install_package "$package"
        done
        ;;
    update)
        update_packages
        ;;
    help|*)
        show_help
        ;;
esac
