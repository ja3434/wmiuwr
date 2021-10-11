#include "apue.h"
#include <stdio.h>
#include <fcntl.h>

#define BUFFSIZE 4096

int main(int argc, char **argv) {
  int n;
  char buf[BUFFSIZE];

  if (argc != 2) {
    printf("Usage: %s <file to output>", argv[0]);
    exit(1);
  }

  int fd = open(argv[1], O_RDONLY);

  while ((n = read(fd, buf, BUFFSIZE)) > 0)
    if (write(STDOUT_FILENO, buf, n) != n)
      err_sys("write error");

  if (n < 0)
    err_sys("read error");

  exit(0);
}
