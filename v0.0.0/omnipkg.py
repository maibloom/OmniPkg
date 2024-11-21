import subprocess
import sys

# Try importing omnipkgupdater (handle if not available)
try:
    from omnipkgupdater import omniupdate
except ImportError:
    omniupdate = None  # Handle the absence of omniupdate function

__version__ = '1.0.1'

class PackageManagers:
    def __init__(self):
        # Commands to check the existence of the package manager
        self.install_commands = {
            "pacman": "sudo pacman -v",
            "apt": "dpkg-query -l",
            "dnf": "dnf --version",
            "yum": "yum --version",
            "zypper": "zypper --version",
            "brew": "brew --version"
        }
        
        # Install commands for different package managers
        self.install_commands_pkg = {
            "pacman": "sudo pacman -S",
            "apt": "sudo apt install",
            "dnf": "sudo dnf install",
            "yum": "sudo yum install",
            "zypper": "sudo zypper install",
            "brew": "brew install"
        }
        
    def check_and_install(self, manager_name):
        """Check if the package manager is installed, install it if not."""
        try:
            # Try running the existence check command for the package manager
            subprocess.run(self.install_commands[manager_name], shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            print(f"{manager_name} is already installed.")
        except subprocess.CalledProcessError:
            print(f"{manager_name} not found. Installing {manager_name}...")
            # Install the package manager if it's not found
            if manager_name == "pacman":
                subprocess.run("sudo pacman -S pacman --noconfirm", shell=True, check=True)
            elif manager_name == "yay":
                print("Installing yay (AUR helper)...")
                # Ensure git and curl are available first
                self.check_and_install("git")
                self.check_and_install("curl")
                subprocess.run("git clone https://aur.archlinux.org/yay.git", shell=True, check=True)
                subprocess.run("cd yay && makepkg -si --noconfirm", shell=True, check=True)
            elif manager_name == "git":
                subprocess.run("sudo pacman -S git --noconfirm", shell=True, check=True)
            elif manager_name == "curl":
                subprocess.run("sudo pacman -S curl --noconfirm", shell=True, check=True)
            else:
                print(f"{manager_name} is not supported for automatic installation on Arch Linux.")

    def install(self, manager_name, packages):
        """Install the specified packages using the selected package manager."""
        self.check_and_install(manager_name)
        
        # Install packages for the specific package manager
        if manager_name == "pacman":
            subprocess.run(f"sudo pacman -Sy {' '.join(packages)}", shell=True)
        elif manager_name == "apt":
            subprocess.run(f"sudo apt install -y {' '.join(packages)}", shell=True)
        elif manager_name == "dnf":
            subprocess.run(f"sudo dnf install -y {' '.join(packages)}", shell=True)
        elif manager_name == "yum":
            subprocess.run(f"sudo yum install -y {' '.join(packages)}", shell=True)
        elif manager_name == "zypper":
            subprocess.run(f"sudo zypper install -y {' '.join(packages)}", shell=True)
        elif manager_name == "brew":
            subprocess.run(f"brew install {' '.join(packages)}", shell=True)

    def update(self, manager_name):
        """Update all packages using the selected package manager."""
        self.check_and_install(manager_name)
        
        if manager_name == "pacman":
            subprocess.run("sudo pacman -Syu", shell=True)
        elif manager_name == "apt":
            subprocess.run("sudo apt update && sudo apt upgrade -y", shell=True)
        elif manager_name == "dnf":
            subprocess.run("sudo dnf update -y", shell=True)
        elif manager_name == "yum":
            subprocess.run("sudo yum update -y", shell=True)
        elif manager_name == "zypper":
            subprocess.run("sudo zypper update -y", shell=True)
        elif manager_name == "brew":
            subprocess.run("brew update && brew upgrade", shell=True)

    def get_package_manager(self):
        """Determine the system's default package manager based on its environment."""
        # Check for the most likely package managers
        for manager in ["pacman", "apt", "dnf", "yum", "zypper", "brew"]:
            try:
                subprocess.run(self.install_commands[manager], shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                return manager  # Return the first one found
            except subprocess.CalledProcessError:
                continue
        raise EnvironmentError("No supported package manager found on this system!")

def main():
    if len(sys.argv) < 2:
        print("Usage: sudo omnipkg -i <package1> [<package2> ...] | sudo omnipkg -u | sudo omnipkg -uo")
        sys.exit(1)

    # Determine the action: install (-i), update (-u) or update using omniupdate (-uo)
    action = sys.argv[1]
    
    # Determine package manager
    package_manager = PackageManagers()
    manager_name = package_manager.get_package_manager()

    if action == "-i":
        # Install the specified packages
        if len(sys.argv) < 3:
            print("Please provide at least one package to install.")
            sys.exit(1)
        packages = sys.argv[2:]
        print(f"Installing {', '.join(packages)} using {manager_name}...")
        package_manager.install(manager_name, packages)
    
    elif action == "-u":
        # Update all installed packages
        print(f"Updating all packages using {manager_name}...")
        package_manager.update(manager_name)
        
    elif action == "-uo" and omniupdate:
        # Call omniupdate if it's available
        print("Running update process using omniupdate...")
        omniupdate()
    
    else:
        print("Invalid action. Use -i to install, -u to update, or -uo to update using omniupdate.")
        sys.exit(1)

if __name__ == "__main__":
    main()
