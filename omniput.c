#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>       // For time(), strftime()
#include <unistd.h>     // For chdir(), getcwd(), rmdir() (though rmdir only works on empty dirs)
#include <sys/stat.h>   // For mkdir(), stat()
#include <sys/types.h>  // For mode_t
#include <errno.h>      // For errno to check mkdir errors
#include <sys/wait.h>   // For WIFEXITED, WEXITSTATUS, WIFSIGNALED, WTERMSIG (from system() status)


#define BASE_TEMP_DIR "/tmp/omnipkg_work" // Base directory for temporary work
#define OMNIPKG_REPO_URL "https://github.com/maibloom/OmniPkg.git" // The actual URL to clone

// Helper function to create a directory if it doesn't exist.
// Returns 0 on success, -1 on failure.
static int ensure_directory_exists(const char *path) {
    struct stat st;
    if (stat(path, &st) == 0) {
        if (S_ISDIR(st.st_mode)) {
            return 0; // Directory already exists
        } else {
            fprintf(stderr, "Error: '%s' exists but is not a directory.\n", path);
            return -1;
        }
    }

    // Try to create the directory
    if (mkdir(path, 0755) == 0) { // 0755 permissions: rwxr-xr-x
        printf("Created directory: %s\n", path);
        return 0;
    } else {
        // Check if the error was that the directory already exists (e.g., race condition)
        if (errno == EEXIST) {
            // Verify it's indeed a directory now
            if (stat(path, &st) == 0 && S_ISDIR(st.st_mode)) {
                return 0;
            }
        }
        perror("Error creating directory");
        fprintf(stderr, "Path: %s\n", path);
        return -1;
    }
}

// Simple recursive directory removal using system("rm -rf").
// WARNING: Be extremely careful with this function.
static int remove_directory_recursive(const char *path) {
    char command[1024];
    // Basic safety checks for the path
    if (path == NULL || strlen(path) == 0 || strcmp(path, "/") == 0 || strcmp(path, "/tmp") == 0 || strstr(path, "..") != NULL) {
        fprintf(stderr, "Error: Invalid or dangerous path for recursive removal: %s\n", path ? path : "NULL");
        return -1;
    }
    snprintf(command, sizeof(command), "rm -rf \"%s\"", path); // Quote path for safety
    printf("Executing: %s\n", command);
    int sys_status = system(command);
    if (sys_status != 0) {
        fprintf(stderr, "Warning: Failed to remove directory '%s'. ", path);
        if (sys_status == -1) {
            perror("System call to rm -rf failed");
        } else {
            if (WIFEXITED(sys_status)) {
                fprintf(stderr, "rm -rf exited with status %d.\n", WEXITSTATUS(sys_status));
            } else if (WIFSIGNALED(sys_status)) {
                fprintf(stderr, "rm -rf was terminated by signal %d.\n", WTERMSIG(sys_status));
            } else {
                fprintf(stderr, "rm -rf command returned non-zero status %d.\n", sys_status);
            }
        }
        return -1;
    }
    printf("Successfully removed directory: %s\n", path);
    return 0;
}

// run_put:
// arg_count: number of elements in args array
// args[0]: action ("install", "remove", "update")
// args[1...N]: package names
void run_put(int arg_count, char *args[]) {
    if (arg_count < 2) { // Must have action and at least one package
        fprintf(stderr, "run_put: Insufficient arguments. Expected <action> <package1> ...\n");
        return;
    }

    const char *action = args[0];
    if (strcmp(action, "install") != 0 && strcmp(action, "remove") != 0 && strcmp(action, "update") != 0) {
        fprintf(stderr, "run_put: Invalid action '%s'. Supported actions are 'install', 'remove', 'update'.\n", action);
        return;
    }

    // Ensure the base temporary directory exists
    if (ensure_directory_exists(BASE_TEMP_DIR) != 0) {
        fprintf(stderr, "Failed to create or access base temporary directory: %s\n", BASE_TEMP_DIR);
        return;
    }

    char original_cwd[1024];
    if (getcwd(original_cwd, sizeof(original_cwd)) == NULL) {
        perror("run_put: Failed to get current working directory");
        return;
    }

    for (int i = 1; i < arg_count; i++) {
        const char *pkgname = args[i];
        printf("\n--- Operating '%s' on package '%s' via OmniPKG's repository ---\n", action, pkgname);

        char timestamp[20];
        time_t now = time(NULL);
        struct tm *t = localtime(&now);
        strftime(timestamp, sizeof(timestamp), "%Y%m%d%H%M%S", t);

        // Create a unique temporary directory for this entire operation (clone + execution)
        // e.g., /tmp/omnipkg_work/google-chrome_op_20250515201412
        char operation_root_dir[512];
        snprintf(operation_root_dir, sizeof(operation_root_dir), "%s/%s_op_%s", BASE_TEMP_DIR, pkgname, timestamp);

        if (ensure_directory_exists(operation_root_dir) != 0) {
            fprintf(stderr, "Failed to create operation root directory: %s\n", operation_root_dir);
            continue; // Skip to the next package
        }

        // Define the path where the OmniPkg repository will be cloned
        // e.g., /tmp/omnipkg_work/google-chrome_op_timestamp/OmniPkg_clone
        char repo_clone_target_dir[600];
        snprintf(repo_clone_target_dir, sizeof(repo_clone_target_dir), "%s/OmniPkg_clone", operation_root_dir);

        // Construct and execute git clone command for the ENTIRE OmniPkg repository
        // Using --depth 1 makes the clone faster by fetching only the latest commit.
        char git_command[1024];
        snprintf(git_command, sizeof(git_command), "git clone --depth 1 %s %s", OMNIPKG_REPO_URL, repo_clone_target_dir);
        printf("Executing: %s\n", git_command);

        int sys_status = system(git_command);
        if (sys_status != 0) {
            fprintf(stderr, "Failed to clone OmniPkg repository for package '%s'. ", pkgname);
            if (sys_status == -1) perror("System call to git clone failed");
            else fprintf(stderr, "Git command exited with status %d.\n", WEXITSTATUS(sys_status));
            remove_directory_recursive(operation_root_dir); // Clean up the operation root directory
            continue; // Skip to the next package
        }
        printf("OmniPkg repository cloned successfully into '%s'.\n", repo_clone_target_dir);

        // Path to the specific package's directory within the cloned repo
        // e.g., /tmp/.../OmniPkg_clone/packages/google-chrome
        char package_dir_in_clone[768];
        snprintf(package_dir_in_clone, sizeof(package_dir_in_clone), "%s/packages/%s", repo_clone_target_dir, pkgname);

        // Path to the script to be executed
        // e.g., /tmp/.../OmniPkg_clone/packages/google-chrome/install.sh
        char script_full_path[1024];
        snprintf(script_full_path, sizeof(script_full_path), "%s/%s.sh", package_dir_in_clone, action);

        // Check if the script file exists
        struct stat script_stat;
        if (stat(script_full_path, &script_stat) != 0) {
            fprintf(stderr, "Error: Script '%s.sh' not found for package '%s' at expected path: %s\n", action, pkgname, script_full_path);
        } else {
            // Change current working directory to the package's directory within the clone
            // Scripts often expect to be run from their own directory to use relative paths.
            if (chdir(package_dir_in_clone) != 0) {
                perror("run_put: Failed to change to package directory within clone");
                fprintf(stderr, "Target directory: %s\n", package_dir_in_clone);
            } else {
                printf("Changed working directory to: %s\n", package_dir_in_clone);

                // Construct and execute the package script command.
                // The script is now referenced by its name (e.g., "./install.sh") as we are in its directory.
                char exec_script_command[512]; // Path is shorter now
                snprintf(exec_script_command, sizeof(exec_script_command), "sudo bash ./%s.sh", action);
                printf("Executing: %s\n", exec_script_command);

                sys_status = system(exec_script_command);
                if (sys_status == 0) {
                    printf("Operation '%s' for package '%s' was successful!\n", action, pkgname);
                } else {
                    fprintf(stderr, "Operation '%s' for package '%s' failed. ", action, pkgname);
                    if (sys_status == -1) perror("System call to execute script failed");
                    else fprintf(stderr, "Script exited with status %d.\n", WEXITSTATUS(sys_status));
                }

                // IMPORTANT: Change back to the original CWD *before* cleanup of operation_root_dir
                if (chdir(original_cwd) != 0) {
                    perror("run_put: CRITICAL error: Failed to change back to original directory from package dir. Cleanup might be unsafe.");
                    // For safety, one might choose to not proceed with recursive deletion if CWD is uncertain.
                } else {
                    printf("Changed working directory back to: %s (from package dir)\n", original_cwd);
                }
            }
        }

        // Always attempt to change back to original_cwd if not already there, before removing operation_root_dir
        // This is a safeguard in case the chdir inside the 'else' block above was skipped due to script not found
        char current_dir_check[1024];
        if (getcwd(current_dir_check, sizeof(current_dir_check)) != NULL && strcmp(current_dir_check, original_cwd) != 0) {
            if (chdir(original_cwd) != 0) {
                 perror("run_put: Warning: Failed to ensure CWD is original_cwd before cleanup.");
            }
        }

        // Clean up the entire temporary directory created for this operation
        remove_directory_recursive(operation_root_dir);
        printf("--- Finished operation for package '%s' ---\n", pkgname);
    }
}

