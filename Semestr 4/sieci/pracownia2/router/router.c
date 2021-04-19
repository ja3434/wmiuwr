#include <stdio.h>
#include <errno.h>
#include <strings.h>
#include <string.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include "network_addr.h"
#include "utils.h"
#include "dist_vector.h"

uint16_t read_configuration(struct network_addr** networks, uint16_t **dists) {
  uint16_t n;
  scanf("%hd", &n);
  *networks = malloc(n * sizeof(struct network_addr));
  *dists    = malloc(n * sizeof(uint16_t));
  for (int i = 0; i < n; i++) {
    char addr[20];
    char _dist[10];
    uint16_t dist;
    scanf(" %s %s %hd", addr, _dist, &dist);
    (*networks)[i] = stona(addr);
    (*dists)[i] = dist;
  }
  return n;
}

void listen_for_routers(int sockfd, int timeout, int networks_number, struct network_addr *networks, uint16_t *dists, list_t *dv) {
  // printf("Listening for %dms.\n", timeout);
  char buffer[IP_MAXPACKET + 1];
  struct sockaddr_in sender;

  while (poll_socket_modify_timeout(sockfd, &timeout)) {
    size_t buf_len = recv_message(sockfd, buffer, &sender);
    struct vector_item new_item = parse_message(buffer, &sender);
    // char addr[20];
    // inet_ntop(AF_INET, &sender.sin_addr, addr, sizeof(addr));
    // printf("Via ip: %s\n", addr);

    if (!is_from_network(sender.sin_addr, new_item.network)) {
      for (int i = 0; i < networks_number; i++) {
          if (is_from_network(sender.sin_addr, networks[i])) {
          new_item.distance += dists[i];
          break;
        }
      }
      new_item.is_connected_directly = false;
    } 

    update_dv_new_item(dv, new_item);
  }
  update_dv_reachability(dv);
  // printf("Finished listening\n\n");
}

void router_loop(int sockfd, int networks_number, struct network_addr *networks, uint16_t *dists) {
  list_t dv = create_list();
  init_dv(&dv, networks_number, networks);

  printf("Starting the router loop...\n");
  for (;;) {
    print_dv(&dv);
    propagate_distance_vector(sockfd, networks_number, networks, dists, &dv);
    listen_for_routers(sockfd, TURN_LEN_MS, networks_number, networks, dists, &dv);
  }
}

int main() {
  struct network_addr* networks;
  uint16_t *dists;
  int n = read_configuration(&networks, &dists);

  int sockfd = get_socket();
  bind_to_port(sockfd, SERVER_PORT);

  router_loop(sockfd, n, networks, dists);

  close(sockfd);
  free(networks);
  free(dists);
}