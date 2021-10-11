#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
  printf("[%d] Ex2, parent pid: %d\n", getpid(), getppid());

  int pid = fork();
  if (pid < 0) {
    printf("Fork error\n");
    exit(1);
  }
  if (pid == 0) {
    for (int i = 0; i < 10; i++) {
      printf("[%d] Child process, parent pid: %d\n", getpid(), getppid());
      sleep(1);
    }
  }
  else {
    printf("[%d] Sleeping for a second.\n", getpid());
    sleep(1);
    printf("[%d] Exit.\n", getpid());
    exit(0);
  }
}