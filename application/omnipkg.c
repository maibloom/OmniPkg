#include <stdio.h>
#include <string.h>
#include <stdlib.h> // For system() and EXIT_SUCCESS, EXIT_FAILURE
#include "omnipkg.h" // Include our header file

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command> [args...]\n", argv[0]);
        fprintf(stderr, "Available commands:\n");
        fprintf(stderr, "  put <action> <package1> [package2...]\n");
        fprintf(stderr, "      Actions: install, remove, update\n");
        fprintf(stderr, "  pacman <package1> [package2...]\n");
        return EXIT_FAILURE; // Standard macro for failure
    }

    if (strcmp(argv[1], "put") == 0) {
        if (argc < 4) { // Need at least: omnipkg put <assction> <package>
            fprintf(stderr, "Usage: %s put <action> <package1> [package2...]\n", argv[0]);
            fprintf(stderr, "Actions: install, remove, update\n");
            return EXIT_FAILURE;
        }
        // Pass the action (argv[2]) and the subsequent package names (&argv[2])
        // The count of arguments for run_put will be argc - 2
        // argv[2] will be action, argv[3] will be first package, etc.
        run_put(argc - 2, &argv[2]);
    } else if (strcmp(argv[1], "pacman") == 0) {
        if (argc < 3) { // Need at least: omnipkg pacman <package>
            fprintf(stderr, "Please provide at least one package name to operate on with pacman.\n");
            return EXIT_FAILURE;
        }
        
        // Dynamically build the pacman command string
        // Calculate required buffer size first for safety
        size_t command_len = strlen("sudo pacman -Syu") + 1; // +1 for space or null terminator
        for (int i = 2; i < argc; i++) {
            command_len += strlen(argv[i]) + 1; // +1 for space
        }

        char *command = malloc(command_len);
        if (command == NULL) {
            perror("Failed to allocate memory for pacman command");
            return EXIT_FAILURE;
        }

        strcpy(command, "sudo pacman -Syu");
        for (int i = 2; i < argc; i++) {
            strcat(command, " ");
            strcat(command, argv[i]);
        }

        printf("Executing: %s\n", command);
        int status = system(command);
        free(command); // Free allocated memory

        if (status == -1) {
            perror("Failed to execute pacman command (system call error)");
            return EXIT_FAILURE;
        } else if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
            fprintf(stderr, "Pacman command failed with exit status %d.\n", WEXITSTATUS(status));
            return EXIT_FAILURE;
        } else if (WIFSIGNALED(status)) {
            fprintf(stderr, "Pacman command terminated by signal %d.\n", WTERMSIG(status));
            return EXIT_FAILURE;
        }
        printf("Pacman command executed successfully.\n");

    } else {
        fprintf(stderr, "Unknown command: %s\n", argv[1]);
        fprintf(stderr, "Run '%s' without arguments to see usage.\n", argv[0]);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS; // Standard macro for success
}

