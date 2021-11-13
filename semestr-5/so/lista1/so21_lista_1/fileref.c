#include "csapp.h"

static char buf[256];

#define LINE1 49
#define LINE2 33
#define LINE3 78

static void do_read(int fd) {
  /* TODO: Spawn a child. Read from the file descriptor in both parent and
   * child. Check how file cursor value has changed in both processes. */
  int pid = fork();
  pid = getpid();
  int offset = lseek(fd, 0, SEEK_CUR);
  printf("[%d] Offset: %d\n", pid, offset);

  int aux = read(fd, buf, LINE1);
  offset = lseek(fd, 0, SEEK_CUR);
  printf("[%d] Offset: %d\n", pid, offset);

  aux = read(fd, buf, LINE2);
  offset = lseek(fd, 0, SEEK_CUR);
  printf("[%d] Offset: %d\n", pid, offset);

  aux = read(fd, buf, LINE3);
  offset = lseek(fd, 0, SEEK_CUR);
  printf("[%d] Offset: %d\n", pid, offset);
  printf("%d\n", aux);
  exit(0);
}

static void do_close(int fd) {
  /* TODO: In the child close file descriptor, in the parent wait for child to
   * die and check if the file descriptor is still accessible. */
  int pid = fork();
  if (pid > 0) {
     printf("[%d] %d\n", getpid(), fcntl(fd, F_GETFD));
     close(fd);
     printf("[%d] %d\n", getpid(), fcntl(fd, F_GETFD));
  }
  else {
    wait(NULL);
    printf("[%d] %d\n", getpid(), fcntl(fd, F_GETFD));
  }
  exit(0);
}

int main(int argc, char **argv) {
  if (argc != 2)
    app_error("Usage: %s [read|close]", argv[0]);

  int fd = Open("test.txt", O_RDONLY, 0);

  if (!strcmp(argv[1], "read"))
    do_read(fd);
  if (!strcmp(argv[1], "close"))
    do_close(fd);
  app_error("Unknown variant '%s'", argv[1]);
}
