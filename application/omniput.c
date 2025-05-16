#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>       // For time(), strftime()
#include <unistd.h>     // For chdir(), getcwd(), remove()
#include <sys/stat.h>   // For mkdir(), stat()
#include <sys/types.h>  // For mode_t
#include <errno.h>      // For errno to check errors
#include <sys/wait.h>   // For WIFEXITED, WEXITSTATUS, WIFSIGNALED, WTERMSIG

// Define these based on your repository
#define OMNIPKG_OWNER "maibloom"
#define OMNIPKG_REPO_NAME "OmniPkg"
#define OMNIPKG_DEFAULT_BRANCH "main" // IMPORTANT: Change if your default branch is different
#define APP_CACHE_DIR_NAME "omnipkg_work" 

// Helper function to ensure a directory exists.
static int ensure_directory_exists(const char *path) {
    struct stat st;
    if (stat(path, &st) == 0) {
        if (S_ISDIR(st.st_mode)) {
            return 0; // Directory already exists
        } else {
            fprintf(stderr, "[ERROR] Path '%s' exists but is not a directory.\n", path);
            return -1;
        }
    }

    if (mkdir(path, 0755) == 0) { // 0755 permissions: rwxr-xr-x
        printf("[INFO] Created directory: %s\n", path);
        return 0;
    } else {
        if (errno == EEXIST) { // Possible race condition: check if it was created by another process
            if (stat(path, &st) == 0 && S_ISDIR(st.st_mode)) {
                return 0;
            }
        }
        fprintf(stderr, "[ERROR] Failed to create directory '%s': %s\n", path, strerror(errno));
        return -1;
    }
}

// Recursively removes a directory using system("rm -rf").
static int remove_directory_recursive(const char *path) {
    char command[1024];
    // Basic safety checks
    if (path == NULL || strlen(path) == 0 || strcmp(path, "/") == 0 || strstr(path, "..") != NULL) {
        fprintf(stderr, "[ERROR] Attempted to remove invalid or dangerous path: %s\n", path ? path : "NULL");
        return -1;
    }

    snprintf(command, sizeof(command), "rm -rf \"%s\"", path);
    printf("[INFO] Cleaning up: %s\n", command);
    int sys_status = system(command);

    if (sys_status != 0) {
        fprintf(stderr, "[WARN] Failed to remove directory '%s'. ", path);
        if (sys_status == -1) {
            fprintf(stderr, "System call error: %s\n", strerror(errno));
        } else {
            if (WIFEXITED(sys_status)) fprintf(stderr, "Command exited with status %d.\n", WEXITSTATUS(sys_status));
            else if (WIFSIGNALED(sys_status)) fprintf(stderr, "Command was terminated by signal %d.\n", WTERMSIG(sys_status));
            else fprintf(stderr, "Command returned unknown non-zero status %d.\n", sys_status);
        }
        return -1;
    }
    printf("[INFO] Successfully removed directory: %s\n", path);
    return 0;
}

void run_put(int arg_count, char *args[]) {
    if (arg_count < 2) {
        fprintf(stderr, "[ERROR] 'put' command requires an action and at least one package name.\n");
        fprintf(stderr, "Usage: omnipkg put <install|remove|update> <package1> [package2...]\n");
        return;
    }

    const char *action = args[0];
    // Corrected 'if' condition for action validation
    if (strcmp(action, "install") != 0 && strcmp(action, "remove") != 0 && strcmp(action, "update") != 0) {
        fprintf(stderr, "[ERROR] Invalid action '%s'. Supported actions are 'install', 'remove', 'update'.\n", action);
        return;
    }

    char base_temp_dir_path[1024];
    const char *home_dir = getenv("HOME");
    if (home_dir == NULL) {
        fprintf(stderr, "[FAIL] HOME environment variable not set. Cannot determine user's cache directory.\n");
        return;
    }

    char user_cache_dir[1024];
    snprintf(user_cache_dir, sizeof(user_cache_dir), "%s/.cache", home_dir);
    if (ensure_directory_exists(user_cache_dir) != 0) {
        fprintf(stderr, "[FAIL] Could not create or access user cache directory: %s.\n", user_cache_dir);
        return;
    }

    snprintf(base_temp_dir_path, sizeof(base_temp_dir_path), "%s/%s", user_cache_dir, APP_CACHE_DIR_NAME);
    printf("[INFO] Using base temporary directory: %s\n", base_temp_dir_path);
    if (ensure_directory_exists(base_temp_dir_path) != 0) {
        fprintf(stderr, "[FAIL] Could not create or access base temporary directory: %s.\n", base_temp_dir_path);
        return;
    }

    char original_cwd[1024];
    if (getcwd(original_cwd, sizeof(original_cwd)) == NULL) {
        fprintf(stderr, "[ERROR] Failed to get current working directory: %s\n", strerror(errno));
        return;
    }

    for (int i = 1; i < arg_count; i++) {
        const char *pkgname = args[i];
        printf("\n>>> Processing package '%s' for action '%s' <<<\n", pkgname, action);

        char timestamp[20];
        time_t now = time(NULL);
        struct tm *t = localtime(&now);
        strftime(timestamp, sizeof(timestamp), "%Y%m%d%H%M%S", t);

        char operation_root_dir[1024];
        snprintf(operation_root_dir, sizeof(operation_root_dir), "%s/%s_op_%s", base_temp_dir_path, pkgname, timestamp);
        
        printf("[INFO] Creating operation directory: %s\n", operation_root_dir);
        if (ensure_directory_exists(operation_root_dir) != 0) {
            fprintf(stderr, "[FAIL] Failed to create operation directory for '%s'. Skipping.\n", pkgname);
            continue;
        }

        char archive_filename_zip[1024];
        snprintf(archive_filename_zip, sizeof(archive_filename_zip), "%s/repo_archive.zip", operation_root_dir);

        char download_url[2048];
        snprintf(download_url, sizeof(download_url), "https://github.com/%s/%s/archive/refs/heads/%s.zip",
                 OMNIPKG_OWNER, OMNIPKG_REPO_NAME, OMNIPKG_DEFAULT_BRANCH);

        char download_command[3072];
        snprintf(download_command, sizeof(download_command), "curl -s -L -o %s %s", archive_filename_zip, download_url); // Added -s for silent curl
        printf("[INFO] Downloading repository archive from GitHub...\n");
        // printf("DEBUG: %s\n", download_command); // Uncomment for debugging download command

        int sys_status = system(download_command);
        if (sys_status != 0) {
            fprintf(stderr, "[ERROR] Failed to download repository archive for '%s'. ", pkgname);
            if (sys_status == -1) { fprintf(stderr, "System call error: %s\n", strerror(errno));}
            else {
                if (WIFEXITED(sys_status)) fprintf(stderr, "Curl command exited with status %d.\n", WEXITSTATUS(sys_status));
                else if (WIFSIGNALED(sys_status)) fprintf(stderr, "Curl command was terminated by signal %d.\n", WTERMSIG(sys_status));
                else fprintf(stderr, "Curl command returned unknown non-zero status %d.\n", sys_status);
            }
            remove_directory_recursive(operation_root_dir);
            fprintf(stderr, "[FAIL] Failed processing package '%s'. Skipping.\n", pkgname);
            continue;
        }
        printf("[INFO] Repository archive downloaded: %s\n", archive_filename_zip);

        printf("[INFO] Changing working directory to: %s for extraction\n", operation_root_dir);
        if (chdir(operation_root_dir) != 0) {
            fprintf(stderr, "[ERROR] Failed to change to operation directory '%s' for extraction: %s\n", operation_root_dir, strerror(errno));
            if (chdir(original_cwd) !=0) { fprintf(stderr, "[WARN] Failed to return to original CWD after chdir failure.\n"); }
            remove_directory_recursive(operation_root_dir);
            fprintf(stderr, "[FAIL] Failed processing package '%s'. Skipping.\n", pkgname);
            continue;
        }

        char extract_command[2048];
        snprintf(extract_command, sizeof(extract_command), "unzip -q repo_archive.zip");
        printf("[INFO] Extracting archive (unzip -q repo_archive.zip)...\n");
        sys_status = system(extract_command);
        // After extraction, delete the zip file
        if (remove("repo_archive.zip") != 0) {
             fprintf(stderr, "[WARN] Could not delete downloaded zip file 'repo_archive.zip': %s\n", strerror(errno));
        }

        if (sys_status != 0) {
            fprintf(stderr, "[ERROR] Failed to extract repository archive for '%s'.\n", pkgname);
             // Full system status error reporting here
            if (chdir(original_cwd) !=0) { fprintf(stderr, "[WARN] Failed to return to original CWD after unzip failure.\n"); }
            remove_directory_recursive(operation_root_dir);
            fprintf(stderr, "[FAIL] Failed processing package '%s'. Skipping.\n", pkgname);
            continue;
        }
        printf("[INFO] Archive extracted.\n");
        
        char extracted_repo_package_path[2048];
        snprintf(extracted_repo_package_path, sizeof(extracted_repo_package_path), "%s-%s/packages/%s", 
                 OMNIPKG_REPO_NAME, OMNIPKG_DEFAULT_BRANCH, pkgname);
        
        printf("[INFO] Changing working directory to package folder: %s\n", extracted_repo_package_path);
        if (chdir(extracted_repo_package_path) != 0) { // This path is relative to current dir (operation_root_dir)
            fprintf(stderr, "[ERROR] Failed to change to extracted package directory '%s': %s\n", extracted_repo_package_path, strerror(errno));
            if (chdir(original_cwd) !=0) { fprintf(stderr, "[WARN] Failed to return to original CWD after chdir to package failure.\n"); }
            remove_directory_recursive(operation_root_dir); // operation_root_dir is absolute
            fprintf(stderr, "[FAIL] Failed processing package '%s'. Skipping.\n", pkgname);
            continue;
        }
        // CWD is now .../operation_root_dir/OmniPkg-main/packages/google-chrome/

        char script_to_execute[512];
        snprintf(script_to_execute, sizeof(script_to_execute), "./%s.sh", action);
        struct stat script_stat;
        if (stat(script_to_execute, &script_stat) != 0) {
            fprintf(stderr, "[ERROR] Script '%s' not found for package '%s'. Expected in current directory.\n", script_to_execute, pkgname);
        } else {
            char exec_script_command[512 + 6]; // "bash " + "./action.sh"
            snprintf(exec_script_command, sizeof(exec_script_command), "bash %s", script_to_execute);
            printf("[INFO] Executing package script: %s (as current user)\n", exec_script_command);
            sys_status = system(exec_script_command);
            
            if (sys_status == 0) { 
                printf("[SUCCESS] Action '%s' for package '%s' completed successfully.\n", action, pkgname);
            } else { 
                fprintf(stderr, "[ERROR] Action '%s' for package '%s' failed. ", action, pkgname);
                if (sys_status == -1) { fprintf(stderr, "System call error: %s\n", strerror(errno));}
                else {
                    if (WIFEXITED(sys_status)) fprintf(stderr, "Script exited with status %d.\n", WEXITSTATUS(sys_status));
                    else if (WIFSIGNALED(sys_status)) fprintf(stderr, "Script was terminated by signal %d.\n", WTERMSIG(sys_status));
                    else fprintf(stderr, "Script returned unknown non-zero status %d.\n", sys_status);
                }
            }
        }
        
        printf("[INFO] Returning to original working directory: %s\n", original_cwd);
        if (chdir(original_cwd) != 0) {
            fprintf(stderr, "[CRITICAL] Failed to change back to original directory '%s': %s.\n", original_cwd, strerror(errno));
            // Not attempting to remove operation_root_dir if we can't get back, to avoid deleting from wrong CWD
        } else {
            // Only remove if we successfully returned to original_cwd
            remove_directory_recursive(operation_root_dir); // operation_root_dir is an absolute path
        }
        printf("<<< Finished processing package '%s' >>>\n", pkgname);
    }
    printf("\nAll package operations complete.\n");
}

