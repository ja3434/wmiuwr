#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

static void signal_handler(int signum) {
  if (signum == SIGINT) {
    write(STDOUT_FILENO, "XD\n", 3);
    _exit(0);
  }
}


int main() {
    signal(SIGINT, signal_handler);
    sigset_t mask;
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);
    // sigfillset(&mask);
    // sigdelset(&mask, SIGINT);
    // sigprocmask(SIG_BLOCK, &mask, NULL);
    // // int *p = NULL;
    // // sleep(10);
    // // *p = 1;
    // // pause();
    // // abort();
    // _exit(0);
    // printf("Lmao\n");
    // while(1) {}
    int sig;
    sigwait(&mask, &sig);
    printf("sig: %d\n", sig);
}