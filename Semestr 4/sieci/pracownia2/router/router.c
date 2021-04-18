#include <stdio.h>
#include <errno.h>
#include <strings.h>
#include <string.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include "router_addr.h"
#include "utils.h"

#define SERVER_PORT 54321
#define TURN_LEN_S 5
#define TURN_LEN_MS (1000 * TURN_LEN_S)
#define TURN_LEN_US (1000000 * TURN_LEN_S)

uint16_t read_configuration(struct router_addr** networks) {
  uint16_t n;
  scanf("%hd", &n);
  *networks = malloc(n * sizeof(struct router_addr));
  for (int i = 0; i < n; i++) {
    char addr[20];
    char _dist[10];
    uint16_t dist;
    scanf(" %s %s %hd", addr, _dist, &dist);
    (*networks)[i] = stora(addr);
    (*networks)[i].distance = dist;
  }
  return n;
}

void listen_for_routers(int sockfd, int timeout, int networks_number, struct router_addr *netowrks) {
  printf("Listening for %dms.\n", timeout);
  while (poll_socket_modify_timeout(sockfd, &timeout)) {
    printf("Poll returned, remaining timeout: %dms.\n", timeout);
    recv_and_print(sockfd, networks_number, netowrks);
  }
  printf("Finished listening\n\n");
}

int send_distance_vector(int sockfd, struct in_addr network) {
  struct sockaddr_in network_address;
  bzero (&network_address, sizeof(network_address));
  network_address.sin_family       = AF_INET;
  network_address.sin_port         = htons(SERVER_PORT);
  network_address.sin_addr         = network;

  char* message = "Hello server! My name is S1\n";
  ssize_t message_len = strlen(message);
  int result;

  char addr[20];
  inet_ntop(AF_INET, &network, addr, sizeof(addr));
  printf("Sending datagram to %s\n", addr);
  if ((result = sendto(sockfd, message, message_len, 0, (struct sockaddr*) &network_address, sizeof(network_address))) != message_len) {
    fprintf(stderr, "sendto error: %s\n", strerror(errno));
  }
}

void propagate_distance_vector(int sockfd, int networks_number, struct router_addr *networks) {
  printf("Propagating distance vector\n");
  for (int i = 0; i < networks_number; i++) {
    struct in_addr broadcast_address = get_broadcast_address(networks[i]);
    send_distance_vector(sockfd, broadcast_address);
  }
  printf("Distance vector propagated.\n\n");
}

void router_loop(int sockfd, int networks_number, struct router_addr *networks) {
  printf("Starting the router loop...\n");
  for (;;) {
    listen_for_routers(sockfd, TURN_LEN_MS, networks_number, networks);
    propagate_distance_vector(sockfd, networks_number, networks);
  }
}

int main() {
  struct router_addr* networks;
  int n = read_configuration(&networks);
  for (int i = 0; i < n; i++) {
    pretty_print(networks[i]);
  }

  int sockfd = get_socket();
  bind_to_port(sockfd, SERVER_PORT);
  router_loop(sockfd, n, networks);

  close(sockfd);
  free(networks);
}