#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h> // For close()

// Forward declarations
void run_put(int argc, char *argv[]); // Actual definition is expected in another .c file (e.g., omniput.c)
void handle_install(int argc, char *argv[]);
void handle_updateall();
void handle_backup(const char *filename);
void handle_restore(const char *filename);

int execute_command(const char *command) {
    printf("Executing: %s\n", command);
    int status = system(command);

    if (status == -1) {
        perror("Failed to execute command (system call error)");
        return EXIT_FAILURE;
    } else if (WIFEXITED(status) && WEXITSTATUS(status) != 0) {
        fprintf(stderr, "Command failed with exit status %d.\n", WEXITSTATUS(status));
        return EXIT_FAILURE;
    } else if (WIFSIGNALED(status)) {
        fprintf(stderr, "Command terminated by signal %d.\n", WTERMSIG(status));
        return EXIT_FAILURE;
    }
    printf("Command executed successfully.\n");
    return EXIT_SUCCESS;
}

void handle_install(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: omnipkg install <manager> <package1> [package2...]\n");
        fprintf(stderr, "Managers: pacman, yay, flathub\n");
        return;
    }

    const char *manager = argv[0];
    char command[4096];
    size_t current_len = 0;

    if (strcmp(manager, "pacman") == 0) {
        current_len = snprintf(command, sizeof(command), "sudo pacman -S --needed");
    } else if (strcmp(manager, "yay") == 0) {
        current_len = snprintf(command, sizeof(command), "yay -S --needed");
    } else if (strcmp(manager, "flathub") == 0) {
        current_len = snprintf(command, sizeof(command), "flatpak install -y flathub");
    } else {
        fprintf(stderr, "Unknown package manager for install: %s\n", manager);
        fprintf(stderr, "Available managers: pacman, yay, flathub\n");
        return;
    }

    if (current_len >= sizeof(command)) {
        fprintf(stderr, "Initial command string too long.\n");
        return;
    }

    for (int i = 1; i < argc; i++) {
        size_t package_len = strlen(argv[i]);
        if (current_len + package_len + 2 > sizeof(command)) {
            fprintf(stderr, "Command string exceeds buffer size while adding package: %s\n", argv[i]);
            return;
        }
        strcat(command, " ");
        strcat(command, argv[i]);
        current_len += package_len + 1;
    }

    execute_command(command);
}

void handle_updateall() {
    printf("Updating all pacman packages...\n");
    if (execute_command("sudo pacman -Syu") != EXIT_SUCCESS) {
        fprintf(stderr, "Pacman update failed.\n");
    }

    printf("\nUpdating all yay (AUR and repo) packages...\n");
    if (execute_command("yay -Syu --noconfirm") != EXIT_SUCCESS) {
        fprintf(stderr, "Yay update failed.\n");
    }

    printf("\nUpdating all flathub packages...\n");
    if (execute_command("flatpak update -y") != EXIT_SUCCESS) {
        fprintf(stderr, "Flatpak update failed.\n");
    }
    printf("\nAll updates attempted.\n");
}

void handle_backup(const char *filename) {
    if (filename == NULL) {
        fprintf(stderr, "Backup filename not provided.\n");
        return;
    }

    char command[512];
    FILE *outfile = fopen(filename, "w");
    if (outfile == NULL) {
        perror("Failed to open backup file for writing");
        return;
    }
    printf("Backing up packages to %s\n", filename);

    printf("Backing up Pacman (native) packages...\n");
    snprintf(command, sizeof(command), "pacman -Qneq");
    FILE *pipe = popen(command, "r");
    if (pipe) {
        char buffer[256];
        while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
            fprintf(outfile, "%s", buffer);
        }
        pclose(pipe);
    } else {
        fprintf(stderr, "Failed to execute pacman -Qneq\n");
    }

    printf("Backing up AUR (foreign) packages...\n");
    snprintf(command, sizeof(command), "pacman -Qmq");
    pipe = popen(command, "r");
    if (pipe) {
        char buffer[256];
        while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
            fprintf(outfile, "aur:%s", buffer);
        }
        pclose(pipe);
    } else {
        fprintf(stderr, "Failed to execute pacman -Qmq\n");
    }
    
    printf("Backing up Flatpak applications...\n");
    snprintf(command, sizeof(command), "flatpak list --app --columns=application");
    pipe = popen(command, "r");
    if (pipe) {
        char buffer[256];
        while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
            fprintf(outfile, "flatpak:%s", buffer);
        }
        pclose(pipe);
    } else {
        fprintf(stderr, "Failed to execute flatpak list\n");
    }

    fclose(outfile);
    printf("Backup completed to %s\n", filename);
}

void handle_restore(const char *filename) {
    if (filename == NULL) {
        fprintf(stderr, "Restore filename not provided.\n");
        return;
    }

    FILE *infile = fopen(filename, "r");
    if (infile == NULL) {
        perror("Failed to open backup file for reading");
        return;
    }
    printf("Restoring packages from %s\n", filename);

    char line[512];
    char command[1024];

    FILE *pacman_pkgs_file = tmpfile();
    FILE *aur_pkgs_file = tmpfile();

    if (!pacman_pkgs_file || !aur_pkgs_file) {
        perror("Failed to create temporary files for package lists");
        fclose(infile);
        if (pacman_pkgs_file) fclose(pacman_pkgs_file);
        if (aur_pkgs_file) fclose(aur_pkgs_file);
        return;
    }
    
    long pacman_count = 0;
    long aur_count = 0;

    while (fgets(line, sizeof(line), infile) != NULL) {
        line[strcspn(line, "\n")] = 0;

        if (strncmp(line, "flatpak:", 8) == 0) {
            char *app_id = line + 8;
            if (strlen(app_id) > 0) {
                snprintf(command, sizeof(command), "flatpak install -y flathub %s", app_id);
                execute_command(command);
            }
        } else if (strncmp(line, "aur:", 4) == 0) {
            char *pkg_name = line + 4;
             if (strlen(pkg_name) > 0) {
                fprintf(aur_pkgs_file, "%s\n", pkg_name);
                aur_count++;
            }
        } else {
            if (strlen(line) > 0) {
                fprintf(pacman_pkgs_file, "%s\n", line);
                pacman_count++;
            }
        }
    }
    fclose(infile);

    if (pacman_count > 0) {
        printf("\nRestoring %ld Pacman packages...\n", pacman_count);
        char temp_pacman_list_name[] = "/tmp/omnipkg_pacman_list_XXXXXX";
        int fd = mkstemp(temp_pacman_list_name);
        if (fd != -1) {
            FILE* named_temp_file = fdopen(fd, "w");
            if (named_temp_file) {
                rewind(pacman_pkgs_file);
                char pkg_buffer[256];
                while(fgets(pkg_buffer, sizeof(pkg_buffer), pacman_pkgs_file)) {
                    fputs(pkg_buffer, named_temp_file);
                }
                fclose(named_temp_file);

                snprintf(command, sizeof(command), "sudo pacman -S --needed --noconfirm --file %s", temp_pacman_list_name);
                execute_command(command);
                remove(temp_pacman_list_name);
            } else {
                 close(fd);
                 perror("Failed to fdopen temporary pacman list file");
            }
        } else {
            perror("Failed to create named temporary file for pacman list");
        }
    }
    fclose(pacman_pkgs_file);

    if (aur_count > 0) {
        printf("\nRestoring %ld AUR packages...\n", aur_count);
        
        char temp_aur_list_name[] = "/tmp/omnipkg_aur_list_XXXXXX";
        int fd_aur = mkstemp(temp_aur_list_name);

        if (fd_aur != -1) {
            FILE* named_temp_aur_file = fdopen(fd_aur, "w");
            if (named_temp_aur_file) {
                rewind(aur_pkgs_file);
                char pkg_buffer[256];
                while(fgets(pkg_buffer, sizeof(pkg_buffer), aur_pkgs_file)) {
                    fputs(pkg_buffer, named_temp_aur_file);
                }
                fclose(named_temp_aur_file);

                snprintf(command, sizeof(command), "yay -S --needed --noconfirm --answerdiff=None --answerclean=None -a %s", temp_aur_list_name);
                execute_command(command);
                remove(temp_aur_list_name);
            } else {
                close(fd_aur);
                perror("Failed to fdopen temporary AUR list file");
            }
        } else {
             perror("Failed to create named temporary file for AUR list");
        }
    }
    fclose(aur_pkgs_file);


    printf("\nPackage restoration process attempted.\n");
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command> [args...]\n", argv[0]);
        fprintf(stderr, "Available commands:\n");
        fprintf(stderr, "  put <action> <package1> [package2...]\n");
        fprintf(stderr, "      Actions: install, remove, update (handled by run_put)\n");
        fprintf(stderr, "  pacman <package1> [package2...]\n");
        fprintf(stderr, "      (Original: Runs sudo pacman -Syu <packages...>)\n");
        fprintf(stderr, "  install <manager> <package1> [package2...]\n");
        fprintf(stderr, "      Managers: pacman, yay, flathub\n");
        fprintf(stderr, "  updateall\n");
        fprintf(stderr, "      Updates packages from pacman, yay, and flathub\n");
        fprintf(stderr, "  backup <filename.txt>\n");
        fprintf(stderr, "      Backs up installed pacman, AUR, and flathub packages\n");
        fprintf(stderr, "  restore <filename.txt>\n");
        fprintf(stderr, "      Restores packages from a backup file\n");
        return EXIT_FAILURE;
    }

    if (strcmp(argv[1], "put") == 0) {
        if (argc < 4) {
            fprintf(stderr, "Usage: %s put <action> <package1> [package2...]\n", argv[0]);
            fprintf(stderr, "Actions: install, remove, update\n");
            return EXIT_FAILURE;
        }
        run_put(argc - 2, &argv[2]);
    } else if (strcmp(argv[1], "pacman") == 0) {
        if (argc < 3) {
            fprintf(stderr, "Please provide at least one package name to operate on with pacman.\n");
            return EXIT_FAILURE;
        }
      
        size_t command_len = strlen("sudo pacman -Syu") + 1;
        for (int i = 2; i < argc; i++) {
            command_len += strlen(argv[i]) + 1;
        }

        char *command_str = malloc(command_len); // Renamed to avoid conflict with 'command' array in other scopes
        if (command_str == NULL) {
            perror("Failed to allocate memory for pacman command");
            return EXIT_FAILURE;
        }

        strcpy(command_str, "sudo pacman -Syu");
        for (int i = 2; i < argc; i++) {
            strcat(command_str, " ");
            strcat(command_str, argv[i]);
        }

        execute_command(command_str);
        free(command_str);

    } else if (strcmp(argv[1], "install") == 0) {
        if (argc < 4) {
            fprintf(stderr, "Usage: %s install <manager> <package1> [package2...]\n", argv[0]);
            fprintf(stderr, "Managers: pacman, yay, flathub\n");
            return EXIT_FAILURE;
        }
        handle_install(argc - 2, &argv[2]);
    } else if (strcmp(argv[1], "updateall") == 0) {
        if (argc != 2) {
            fprintf(stderr, "Usage: %s updateall\n", argv[0]);
            return EXIT_FAILURE;
        }
        handle_updateall();
    } else if (strcmp(argv[1], "backup") == 0) {
        if (argc != 3) {
            fprintf(stderr, "Usage: %s backup <filename.txt>\n", argv[0]);
            return EXIT_FAILURE;
        }
        handle_backup(argv[2]);
    } else if (strcmp(argv[1], "restore") == 0) {
        if (argc != 3) {
            fprintf(stderr, "Usage: %s restore <filename.txt>\n", argv[0]);
            return EXIT_FAILURE;
        }
        handle_restore(argv[2]);
    } else {
        fprintf(stderr, "Unknown command: %s\n", argv[1]);
        fprintf(stderr, "Run '%s' without arguments to see usage.\n", argv[0]);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}