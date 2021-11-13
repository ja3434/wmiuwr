#include "csapp.h"

static pid_t spawn(void (*fn)(void)) {
  pid_t pid = Fork();
  if (pid == 0) {
    fn();
    printf("(%d) I'm done!\n", getpid());
    exit(EXIT_SUCCESS);
  }
  return pid;
}

static void grandchild(void) {
  printf("(%d) Waiting for signal!\n", getpid());
  pause();
  printf("(%d) Got the signal!\n", getpid());
}

static void child(void) {
  pid_t pid;
  setpgid(0, 0);
  pid = spawn(grandchild);
  printf("(%d) Grandchild (%d) spawned!\n", getpid(), pid);
}

/* Runs command "ps -o pid,ppid,pgrp,stat,cmd" using execve(2). */
static void ps(void) {
  pid_t pid = Fork();
  if (pid == 0) {
    if (execlp("ps", "ps", "-o", "pid,ppid,pgrp,stat,cmd", NULL) < 0) {
      fprintf(stderr, "Exec error: %s\n", strerror(errno));
      exit(EXIT_FAILURE);
    }
  }
  waitpid(pid, NULL, 0);
}

int main(void) {
  /* TODO: Make yourself a reaper. */
#ifdef LINUX
  Prctl(PR_SET_CHILD_SUBREAPER, 1);
#endif
  printf("(%d) I'm a reaper now!\n", getpid());

  pid_t pid, pgrp;
  int status;

  /* TODO: Start child and grandchild, then kill child!
   * Remember that you need to kill all subprocesses before quit. */
  pid = spawn(child);
  pgrp = pid;
  waitpid(pid, &status, 0);
  ps();

  Kill(-pgrp, SIGINT);
  pid = wait(&status);
  printf("Reaped the grandchild (%d), exit code: %d\n", pid, status);
  return EXIT_SUCCESS;
}
