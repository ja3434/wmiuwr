#include <signal.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

volatile int *p = NULL;
int x = 0;

void segv_handler(int signum) {
  char text[100];
  sprintf(text, "Segv handler! p: %p\n", p);
  if (p == NULL)
    p = &x;
  write(STDOUT_FILENO, text, strlen(text));
}

int main() {
  signal(SIGSEGV, segv_handler);

  *p = 1;
}
