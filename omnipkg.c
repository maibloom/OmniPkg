#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> // Include for getuid() and geteuid()

#define MAX_INPUT_LENGTH 100
#define MAX_PACKAGES 10  // Define a maximum number of packages for input

// Function declarations
void update_package_manager(const char *manager);
int check_package_manager(const char *manager, const char *package);
void install_package(const char *manager, const char *package);
void print_help();
int is_running_as_sudo();

int main(int argc, char *argv[]) {
    // Check if the program is run with sudo
    if (!is_running_as_sudo()) {
        fprintf(stderr, "Error: This program must be run with sudo.\n");
        return EXIT_FAILURE;  // Logic for wrong entry
    }

    // Check if any arguments are provided
    if (argc < 2) {
        fprintf(stderr, "Error: No package names provided.\n");
        print_help();  // Print help message
        return EXIT_FAILURE;  // Logic for wrong entry
    }

    const char *package_managers[] = {"pacman", "yay", "apt", "dnf", "zypper", "flatpak", "snap"};
    int num_managers = sizeof(package_managers) / sizeof(package_managers[0]);

    // Iterate over each provided package name
    for (int i = 1; i < argc; i++) {
        const char *package_name = argv[i];

        // Check for valid package name (can be expanded based on your criteria)
        if (strlen(package_name) == 0) {
            fprintf(stderr, "Error: Invalid package name '%s'.\n", package_name);
            continue;  // Skip to the next package name
        }

        // Iterate over each package manager
        for (int j = 0; j < num_managers; j++) {
            const char *manager = package_managers[j];

            // Update the package manager
            printf("Updating package database for %s...\n", manager);
            update_package_manager(manager);

            // Check if the package manager can handle the package
            if (check_package_manager(manager, package_name)) {
                printf("Installing %s using %s...\n", package_name, manager);
                install_package(manager, package_name);
                break;  // Exit the loop once the package is successfully installed
            } else {
                printf("%s cannot handle %s.\n", manager, package_name);
            }
        }

        // If no package manager could install the package
        printf("No suitable package manager found to install %s.\n", package_name);
    }

    return EXIT_SUCCESS;
}

// Function to check if the program is run with sudo
int is_running_as_sudo() {
    return geteuid() == 0; // Returns 1 if running as root (sudo), otherwise 0
}

// Function to update the package database for a specific package manager
void update_package_manager(const char *manager) {
    char command[MAX_INPUT_LENGTH];
    
    // Construct the command based on the package manager
    if (strcmp(manager, "apt") == 0) {
        snprintf(command, sizeof(command), "sudo apt-get update");
    } else if (strcmp(manager, "dnf") == 0) {
        snprintf(command, sizeof(command), "sudo dnf makecache");
    } else if (strcmp(manager, "zypper") == 0) {
        snprintf(command, sizeof(command), "sudo zypper refresh");
    } else if (strcmp(manager, "flatpak") == 0) {
        snprintf(command, sizeof(command), "flatpak update --appstream");
    } else if (strcmp(manager, "snap") == 0) {
        snprintf(command, sizeof(command), "sudo snap refresh");
    } else if (strcmp(manager, "pacman") == 0) {
        snprintf(command, sizeof(command), "sudo pacman -Sy");
    } else if (strcmp(manager, "yay") == 0) {
        snprintf(command, sizeof(command), "yay -Sy");
    } else {
        fprintf(stderr, "Unknown package manager: %s\n", manager);
        return; // Skip unknown managers
    }

    // Execute the command to update the package database
    system(command);
}

// Function to check if a package manager can handle a specific package
int check_package_manager(const char *manager, const char *package) {
    char command[MAX_INPUT_LENGTH];
    
    // Construct a command to check if the package is available
    snprintf(command, sizeof(command), "%s -Qi %s", manager, package); // Check if the package exists
    return system(command) == 0;  // Returns 0 if the package exists
}

// Function to install the package using the specified package manager
void install_package(const char *manager, const char *package) {
    char command[MAX_INPUT_LENGTH];
    
    // Construct the command to install the package
    snprintf(command, sizeof(command), "sudo %s -S --needed %s", manager, package);
    system(command);
}

// Function to print help message
void print_help() {
    printf("Usage: omnipkg <package_name1> <package_name2> ... <package_nameN>\n");
    printf("Installs the specified packages using available package managers.\n");
    printf("Supported package managers: pacman, yay, apt, dnf, zypper, flatpak, snap.\n");
}
