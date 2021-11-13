#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <errno.h>

void sig_handler(int signum) {
  char text[100];
  sprintf(text, "[%d] Hello, I'm a signal handler :)\n", getpid());
  write(STDOUT_FILENO, text, strlen(text));
}

int main() {
  signal(SIGUSR1, sig_handler);
  printf("Parent: [%d]\n", getpid());
  fflush(stdout);
  if (fork() == 0) {
    printf("Child: [%d]\n", getpid());
    // while(1) {}
    if (execl("./echo-my", "echo-my", NULL) < 0) {
      fprintf(stderr, "Exec error: %s\n", strerror(errno));
      exit(0);
    }
  }

  int result;
  wait(&result);
}
