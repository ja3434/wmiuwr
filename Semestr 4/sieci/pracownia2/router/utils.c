#include "utils.h"
#include <arpa/inet.h>
#include <netinet/ip.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

int get_socket() {
  int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) {
    fprintf(stderr, "Socket error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  return sockfd;
}

void bind_to_port(int sockfd, uint16_t port) {
  struct sockaddr_in server_address;
  bzero(&server_address, sizeof(server_address));
  server_address.sin_family       = AF_INET;
  server_address.sin_port         = htons(port);
  server_address.sin_addr.s_addr  = htonl(INADDR_ANY);
  if (bind(sockfd, (struct sockaddr*)&server_address, sizeof(server_address)) < 0) {
    fprintf(stderr, "Bind error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  int broadcastPermission = 1;
  setsockopt (sockfd, SOL_SOCKET, SO_BROADCAST, (void *)&broadcastPermission, sizeof(broadcastPermission));
}

long get_time_interval(struct timespec start, struct timespec finish) {
  return S_TO_MS(finish.tv_sec - start.tv_sec) + NS_TO_MS(finish.tv_nsec - start.tv_nsec);
}

int poll_socket_modify_timeout(int sockfd, int *timeout) {
  if (*timeout < 0) {
    fprintf(stderr, "poll_modify_timeout: timeout is negative.\n");
    exit(EXIT_FAILURE);
  }
  
  struct pollfd fds;
  fds.fd = sockfd;
  fds.events = POLLIN;
  fds.revents = 0;

  struct timespec start;
  clock_gettime(CLOCK_REALTIME, &start);
  int result = poll(&fds, 1, *timeout);
  
  if (result == -1) {
    fprintf(stderr, "poll error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  if (result == 0) {
    *timeout = 0;
    return 0;
  }
  struct timespec finish;
  clock_gettime(CLOCK_REALTIME, &finish);
  *timeout -= get_time_interval(start, finish);
  printf("Timeout: %dms, time waiting: %ldms.\n", *timeout, get_time_interval(start, finish));
  return result;
}   

/* For debug purposes only */
void recv_and_print(int sockfd, int networks_number, struct router_addr *networks) {
  struct sockaddr_in  sender;
  socklen_t           sender_len = sizeof(sender);
  uint8_t             buffer[IP_MAXPACKET + 1];
  ssize_t datagram_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0,
    (struct sockaddr*)&sender, &sender_len);
  if (datagram_len < 0) {
    fprintf(stderr, "recvfrom error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  for (int i = 0; i < networks_number; i++) {
    if (networks[i].addr.s_addr == sender.sin_addr.s_addr) {
      return;
    }
  }
 
  char sender_ip_str[20];
  inet_ntop(AF_INET, &(sender.sin_addr), sender_ip_str, sizeof(sender_ip_str));
  printf("Received UDP packet from IP address: %s, port %d\n", 
    sender_ip_str, ntohs(sender.sin_port));

  buffer[datagram_len] = 0;
  printf("%ld-byte message: +%s+\n", datagram_len, buffer);
}