#include "utils.h"
#include <arpa/inet.h>
#include <netinet/ip.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

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

size_t send_message(int sockfd, char *buffer, int buffer_len, struct in_addr network) {
  struct sockaddr_in network_address;
  bzero (&network_address, sizeof(network_address));
  network_address.sin_family       = AF_INET;
  network_address.sin_port         = htons(SERVER_PORT);
  network_address.sin_addr         = network;
  
  return sendto(sockfd, buffer, buffer_len, 0, (struct sockaddr*) &network_address, sizeof(network_address));
}

size_t recv_message(int sockfd, char *buffer, struct sockaddr_in *sender) {
  socklen_t sender_len = sizeof(*sender);
  for (int i = 0; i < DV_DATAGRAM_LEN; i++) buffer[i] = 0;
  size_t datagram_len = recvfrom(sockfd, buffer, IP_MAXPACKET, 0,
    (struct sockaddr*)sender, &sender_len);
  if (datagram_len < 0) {
    fprintf(stderr, "recvfrom error: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  // printf("Received a message: ");
  // for (int i = 0 ; i < 9; i++) {
  //   printf("%u ", (uint8_t)buffer[i]);
  // }
  // printf("\n");
  return datagram_len;
}

struct vector_item parse_message(char *buffer, struct sockaddr_in *sender) {
  // printf("Parsing a message: ");
  // for (int i = 0 ; i < 9; i++) {
  //   printf("%u ", (uint8_t)buffer[i]);
  // }
  // printf("\n");
  struct vector_item res;
  uint32_t ip_addr  = *(uint32_t *)buffer;
  // ip_addr           = ip_addr;
  uint32_t dist     = *(uint32_t *)(buffer + 5);
  dist              = ntohl(dist);

  res.network.addr.s_addr   = ip_addr;
  res.network.netmask       = buffer[4];
  res.is_connected_directly = true;
  res.via_ip                = sender->sin_addr;
  res.distance              = (dist < INFINITY_DIST ? dist : INFINITY_DIST);
  res.reachable             = 0;

  char addr[20];
  inet_ntop(AF_INET, &res.network.addr, addr, sizeof(addr));
  char via[20];
  inet_ntop(AF_INET, &sender->sin_addr, via, sizeof(via));
  
  // printf("Po ludzku: %s/%d, distance %d, via %s\n", addr,  res.network.netmask, res.distance, via);

  return res;
}

void _get_message(struct vector_item item, char *message) {
  *(uint32_t *)message  = item.network.addr.s_addr;
  message[4]            = item.network.netmask;
  uint32_t distance     = htonl(item.distance >= INFINITY_DIST ? INT_MAX : item.distance);
  for (int i = 0; i < 4; i++) {
    *(message + 5 + i) = *((char *)(&distance) + i); 
  }
}

int _send_item(int sockfd, struct network_addr network, struct vector_item item) {
  char message[DV_DATAGRAM_LEN + 1];
  _get_message(item, message);
  message[DV_DATAGRAM_LEN] = 0;
  ssize_t message_len = DV_DATAGRAM_LEN;

  struct in_addr na = get_broadcast_address(network);
  
  char addr[20];
  inet_ntop(AF_INET, &na, addr, sizeof(addr));
  // printf("Sending datagram to %s: ", addr);
  // for (int i = 0 ; i < DV_DATAGRAM_LEN; i++) {
  //   printf("%u ", (uint8_t)message[i]);
  // }
  // printf("\nmessage_len: %ld\n", message_len);
  int result;
  if ((result = send_message(sockfd, message, message_len, na)) != message_len) {
    // fprintf(stderr, "sendto error: %s\n", strerror(errno));
  }
  return result;
}

void listen_for_routers(int sockfd, int timeout, int networks_number, struct network_addr *networks, uint16_t *dists, list_t *dv) {
  // printf("Listening for %dms.\n", timeout);
  char buffer[IP_MAXPACKET + 1];
  struct sockaddr_in sender;

  while (poll_socket_modify_timeout(sockfd, &timeout)) {
    size_t buf_len = recv_message(sockfd, buffer, &sender);
    struct vector_item new_item = parse_message(buffer, &sender);

    bool is_neighbour = false;
    for (int i = 0; i < networks_number; i++) {
      if (is_from_network(sender.sin_addr, networks[i])) {
        is_neighbour = true;
        break;
      }
    }

    /* Shouldn't happen, just in case. */
    if (!is_neighbour) {
      char addr[20];
      inet_ntop(AF_INET, &sender.sin_addr, addr, sizeof(addr));
      fprintf(stderr, "Received datagram from %s, he is in none of my networks, ignoring\n. Maybe his VM routing table is configured incorrectly?\n", addr);
      continue;
    }

    if (!is_from_network(sender.sin_addr, new_item.network)) {
      new_item.is_connected_directly = false;

      for (int i = 0; i < networks_number; i++) {
          if (is_from_network(sender.sin_addr, networks[i])) {
          new_item.distance += dists[i];
          break;
        }
      }
    } 

    update_dv_new_item(dv, new_item);
  }
  update_dv_reachability(dv);
}

void propagate_distance_vector(int sockfd, int networks_number, struct network_addr *networks, uint16_t *dists, list_t *dv) {
  for (int i = 0; i < networks_number; i++) {
    reset(dv);
    while (dv->it != NULL) {
      struct vector_item data = *(struct vector_item *)dv->it->data;
      if (!(get_network_address(data.network).s_addr == get_network_address(networks[i]).s_addr) && data.reachable <= REACHABILITY_WAIT_TIME) {
        _send_item(sockfd, networks[i], data);
      }
      iterate(dv);
    }

    struct vector_item self_item;
    self_item.distance = dists[i];
    self_item.network = networks[i];    
    // printf("Sending self message: %d\n", dists[i]);
    _send_item(sockfd, networks[i], self_item);
  }
}

bool is_from_network(struct in_addr ip_addr, struct network_addr network) {
  struct network_addr temp;
  temp.addr= ip_addr;
  temp.netmask = network.netmask;
  return (get_network_address(temp).s_addr == get_network_address(network).s_addr);
}