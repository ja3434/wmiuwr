#include "csapp.h"

bool f_lock(const char *path) {
    if (open(path, O_CREAT|O_WRONLY|O_EXCL, 0700) == -1) {
        if (errno != EEXIST) {
            printf("%s\n", strerror(errno)); 
            exit(EXIT_FAILURE);
        }
        printf("%s\n", strerror(errno)); 
        return false;
    }
    return true;
}

void f_unlock(const char *path) {
    Unlink(path);
}


const char *name = "lock";

int main(void) {
    while (1) {
        if (f_lock(name)) {
            // printf("Hello\n");
            f_unlock(name);
        }
    }
}