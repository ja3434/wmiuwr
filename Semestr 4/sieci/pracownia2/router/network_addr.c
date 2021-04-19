#include "network_addr.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct in_addr _get_broadcast_address(struct in_addr addr, uint16_t netmask) {
  struct in_addr result = addr;
  /* bitshift by more than 31 is UB */
  if (netmask < 32) {
    result.s_addr |= ~((1<<netmask) - 1);
  }
  return result;
}

struct in_addr _get_network_address(struct in_addr addr, uint16_t netmask) {
  struct in_addr result = addr;
  if (netmask == 0) {
    addr.s_addr = 0;
  }
  else {
    result.s_addr &= ~((1 << (32 - netmask)) - 1);
  }
  return result;
}

struct in_addr get_broadcast_address(struct network_addr na) {
  return _get_broadcast_address(na.addr, na.netmask);
}

struct in_addr get_network_address(struct network_addr na) {
  return _get_network_address(na.addr, na.netmask);
}

void pretty_print(struct network_addr na) {
  char ip_addr[20];
  inet_ntop(AF_INET, &na.addr, ip_addr, sizeof(ip_addr));
  printf("%s/%d distance %d\n", ip_addr, na.netmask, na.distance);
}

struct network_addr stora(char *str) {
  struct network_addr  result;
  char                addr[20];
  size_t              ip_preffix = strcspn(str, "/");
  
  strncpy(addr, str, strlen(str));
  addr[ip_preffix] = 0;
  inet_pton(AF_INET, addr, &(result.addr));
  result.netmask = atoi(str + ip_preffix + 1);
  return result;
}
