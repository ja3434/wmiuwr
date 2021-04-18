#ifndef UTILS_H
#define UTILS_H
#define UTILS_H

#include <stdint.h>
#include <time.h>
#include <poll.h>
#include "router_addr.h"

#define NS_TO_MS(X) ((long)(X) / (long)1000000)
#define S_TO_MS(X) ((long)(X) * (long)1000)

int get_socket();

void bind_to_port(int sockfd, uint16_t port);

long get_time_interval(struct timespec start, struct timespec finish);

int poll_socket_modify_timeout(int sockfd, int *timeout);

void recv_and_print(int sockfd, int networks_number, struct router_addr *networks);

#endif