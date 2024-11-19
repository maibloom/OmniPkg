import subprocess
import sys
from omnipkgupdater import omniupdate

__version__ = '1.0.0'

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
        except subprocess.CalledProcessError:
            print(f"{manager_name} not found. Installing {manager_name}...")
            # Install the package manager if it's not found
            if manager_name == "pacman":
                subprocess.run("sudo pacman -S pacman", shell=True, check=True)
            elif manager_name == "apt":
                subprocess.run("sudo apt update && sudo apt install apt", shell=True, check=True)
            elif manager_name == "dnf":
                subprocess.run("sudo dnf install dnf", shell=True, check=True)
            elif manager_name == "yum":
                subprocess.run("sudo yum install yum", shell=True, check=True)
            elif manager_name == "zypper":
                subprocess.run("sudo zypper install zypper", shell=True, check=True)
            elif manager_name == "brew":
                subprocess.run("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"", shell=True, check=True)

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
    if len(sys.argv) < 3:
        print("Usage: sudo omnipkg -i <package1> [<package2> ...] | sudo omnipkg -u")
        sys.exit(1)

    # Determine the action: install (-i) or update (-u)
    action = sys.argv[1]
    
    # Determine package manager
    package_manager = PackageManagers()
    manager_name = package_manager.get_package_manager()

    if action == "-i":
        # Install the specified packages
        packages = sys.argv[2:]
        print(f"Installing {', '.join(packages)} using {manager_name}...")
        package_manager.install(manager_name, packages)
    
    elif action == "-u":
        # Update all installed packages
        print(f"Updating all packages using {manager_name}...")
        package_manager.update(manager_name)
        
    elif action == "-uo":
        omniupdate()
    
    else:
        print("Invalid action. Use -i to install or -u to update.")
        sys.exit(1)

if __name__ == "__main__":
    main()
