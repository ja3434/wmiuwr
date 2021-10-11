#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main() {
  int pid = fork();
  if (pid < 0) {
    printf("Fork error\n");
    exit(1);
  }
  if (pid == 0) {
    printf("[%d], Child process, returning.\n", getpid());
    exit(0);
  }
  else {
    while (1) {
      printf("[%d] Parent process, sleeping.\n", getpid());
      sleep(1);
    }
  }
}