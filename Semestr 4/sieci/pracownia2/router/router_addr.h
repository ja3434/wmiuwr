#ifndef ROUTER_ADDR_H
#define ROUTER_ADDR_H

#include <arpa/inet.h>
#include <stdint.h>

struct router_addr {
  struct in_addr  addr;
  uint16_t        distance;
  uint8_t         netmask;
};

struct in_addr get_broadcast_address(struct router_addr ra);

void pretty_print(struct router_addr ra);

struct router_addr stora(char *str);

#endif