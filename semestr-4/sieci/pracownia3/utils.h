#ifndef UTILS_H
#define UTILS_H

#include <stddef.h>
#include <time.h>

#define NS_TO_MS(X) ((long)(X) / (long)1000000)
#define S_TO_MS(X) ((long)(X) * (long)1000)

size_t min(size_t x, size_t y);

int get_socket();

long get_time_interval(struct timespec start, struct timespec finish);

int poll_socket_modify_timeout(int sockfd, int *timeout);

#endif