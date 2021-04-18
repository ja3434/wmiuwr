#include "router_addr.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct in_addr get_broadcast_address(struct router_addr ra) {
  struct in_addr result = ra.addr;
  /* bitshift by more than 31 is UB */
  if (ra.netmask < 32) {
    result.s_addr |= ~((1<<ra.netmask) - 1);
  }
  return result;
}

void pretty_print(struct router_addr ra) {
  char ip_addr[20];
  inet_ntop(AF_INET, &ra.addr, ip_addr, sizeof(ip_addr));
  printf("%s/%d distance %d\n", ip_addr, ra.netmask, ra.distance);
}

/* converts string of IP with netmask in CIDR notation to router_addr */
struct router_addr stora(char *str) {
  struct router_addr  result;
  char                addr[20];
  size_t              ip_preffix = strcspn(str, "/");
  
  strncpy(addr, str, strlen(str));
  addr[ip_preffix] = 0;
  inet_pton(AF_INET, addr, &(result.addr));
  result.netmask = atoi(str + ip_preffix + 1);
  return result;
}