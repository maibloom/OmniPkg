# Omni Package Manager

Omni Package Manager helps you to search out the variety of package managers, take a backup from your installed files, and install listed files together.

**This package manager is currently for Arch Linux.**

# GUIDE

## How to install

just copy and paste this command:

```
sudo pacman -Sy git
git clone https://github.com/devtracer/OmniPkg.git
cd OmniPkg
chmod +x Installer.sh && ./Installer.sh
```

## Commands

| Command name | Syntax                                             | Description                                                               |
|--------------|----------------------------------------------------|---------------------------------------------------------------------------|
| `install`    | `omnipkg install <package1> <package2> ... <packagen>` | Install specified package(s) using the available package manager(s).      |
| `update`     | `omnipkg update`                                   | Updates all installed packages using the available package manager(s).     |
| `backup`     | `omnipkg backup`                                   | Backs up all installed packages into a `.txt` file, allowing you to restore them later. |
| `batch`      | `omnipkg batch /path/to/packagelist.txt`           | Installs packages listed in a `.txt` file, allowing you to restore packages from a backup. |          
