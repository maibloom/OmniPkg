#ifndef OMNIPKG_H
#define OMNIPKG_H

// Declare functions from Omniput.c that Omnipkg.c will use
// The first argument is the count of strings in 'args',
// where args[0] is the action (e.g., "install"), and subsequent elements are package names.
void run_put(int arg_count, char *args[]);

#endif // OMNIPKG_H


