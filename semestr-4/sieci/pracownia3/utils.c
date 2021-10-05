/* Projekt: Transport
 * Autor: Franciszek Malinka 316093
 */

#include "utils.h"
#include <poll.h>
#include <errno.h>
#include <stdio.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>

size_t min(size_t x, size_t y) { return (x<y ? x : y); }

int get_socket() {
  int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) {
    fprintf(stderr, "socket error: %s", strerror(errno));
    exit(EXIT_FAILURE);
  }
  return sockfd;
}

long get_time_interval(struct timespec start, struct timespec finish) {
  return S_TO_MS(finish.tv_sec - start.tv_sec) + NS_TO_MS(finish.tv_nsec - start.tv_nsec);
}

int poll_socket_modify_timeout(int sockfd, int *timeout) {
  if (*timeout < 0) {
    *timeout = 0;
    return 0;
  }

  struct pollfd fds;
  struct timespec start;
  struct timespec finish;
  
  fds.fd = sockfd;
  fds.events = POLLIN;
  fds.revents = 0;
  
  clock_gettime(CLOCK_REALTIME, &start);
  int result = poll(&fds, 1, *timeout);
  clock_gettime(CLOCK_REALTIME, &finish);
  
  if (result == -1) {
    fprintf(stderr, "poll error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  if (result == 0) {
    *timeout = 0;
    return 0;
  }

  *timeout -= get_time_interval(start, finish);
  return result;
}
