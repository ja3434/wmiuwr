#ifndef ROUTER_ADDR_H
#define ROUTER_ADDR_H

#include <arpa/inet.h>
#include <stdint.h>
#include <stdbool.h>

#define INFINITY_DIST 128

/* Network address and sitance */
struct network_addr {
  struct in_addr  addr;
  uint16_t        distance;
  uint8_t         netmask;
};

typedef struct network_addr router_addr;

/* Returns broadcast address of a given network. */
struct in_addr get_broadcast_address(struct network_addr na);

/* Returns network address of a given network */
struct in_addr get_network_address(struct network_addr na);

/* Prints network_addr via stdio. */
void pretty_print(struct network_addr na);

/* Converts string of ip in CIDR notation with a netmask to network_addr. */
struct network_addr stora(char *str);


#endif