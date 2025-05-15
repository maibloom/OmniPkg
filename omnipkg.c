#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void run_put();

int main(int argc, char *argv[]) {

    if (argc < 2) {
        printf("Please provide some arguments.\n");
        return 1;
    }
    
    if (strcmp(argv[1], "put") == 0) {
        run_put();
    } else if (strcmp(argv[1], "pacman") == 0) {
        if (argc < 3) {
            printf("Please provide a package name to install.\n");
            return 1;
        }
        char command[256];
        snprintf(command, sizeof(command), "sudo pacman -Syu %s", argv[2]);
        system(command);
    }

    return 0; // Return 0 to indicate success
}
