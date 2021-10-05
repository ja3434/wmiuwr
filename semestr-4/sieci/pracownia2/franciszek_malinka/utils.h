#ifndef UTILS_H
#define UTILS_H
#define UTILS_H

#include "config.h"
#include <stdint.h>
#include <time.h>
#include <poll.h>
#include "network_addr.h"
#include "dist_vector.h"

#define NS_TO_MS(X) ((long)(X) / (long)1000000)
#define S_TO_MS(X) ((long)(X) * (long)1000)

/* Returns a UDP socket. */
int get_socket();

/* Binds socket to given port and set the broadcast permission. */
void bind_to_port(int sockfd, uint16_t port);

/* Computes the time elapsed between start and finish in miliseconds. */
long get_time_interval(struct timespec start, struct timespec finish);

/* Polls given socket with given timeout and changes the timeout accordingly. */
int poll_socket_modify_timeout(int sockfd, int *timeout);

/* For debug purposes only. Recieves and prints UDP message. */
void recv_and_print(int sockfd, int networks_number, struct network_addr *networks);

/* Sends message in buffer of length buffer_len to addr through given socket. 
 * IT DOES NOT TERMINATE THE PROGRAM IF SENDTO RETURNS ANY ERRORS! 
 * One must handle the errors on their own. 
 */  
size_t send_message(int sockfd, char *buffer, int buffer_len, struct in_addr addr);

/* Receive message and write it to buffer. */
size_t recv_message(int sockfd, char *buffer, struct sockaddr_in *sender);

/* Parse datagram into a vector item. */
struct vector_item parse_message(char *buffer, struct sockaddr_in *sender);

/* Listnes for routers for timeout ms. */
void listen_for_routers(int sockfd, int timeout, int networks_number, struct network_addr *networks, uint16_t *dists, list_t *dv);

/* Propagates dv to all connected networks. */
void propagate_distance_vector(int sockfd, int networks_number, struct network_addr *networks, uint16_t *dists, list_t *dv);

/* Checks if given address is in network range. */
bool is_from_network(struct in_addr ip_addr, struct network_addr network);
 

#endif