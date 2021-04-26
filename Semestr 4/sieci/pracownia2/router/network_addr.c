/*
 *  Program:  router
 *  Autor:    Franciszek Malinka, 316093
 */

#include "network_addr.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct in_addr _get_broadcast_address(struct in_addr addr, uint16_t netmask) {
  struct in_addr result = addr;
  result.s_addr = ntohl(result.s_addr);
  /* bitshift by more than 31 is UB */
  if (netmask == 0) {
    result.s_addr = -1;
  }
  else {
    result.s_addr |= ((1 << (32 - netmask)) - 1);
  }
  result.s_addr = htonl(result.s_addr);

  return result;
}

struct in_addr _get_network_address(struct in_addr addr, uint16_t netmask) {
  struct in_addr result = addr;
  result.s_addr = ntohl(result.s_addr);

  if (netmask == 0) {
    result.s_addr = 0;
  }
  else {
    result.s_addr &= ~((1 << (32 - netmask)) - 1);
  }
  result.s_addr = htonl(result.s_addr);

  return result;
}

struct in_addr get_broadcast_address(struct network_addr na) {
  return _get_broadcast_address(na.addr, na.netmask);
}

struct in_addr get_network_address(struct network_addr na) {
  return _get_network_address(na.addr, na.netmask);
}

void pretty_print_network(struct network_addr na) {
  char ip_addr[20];
  inet_ntop(AF_INET, &na.addr, ip_addr, sizeof(ip_addr));
  printf("%s/%d\n", ip_addr, na.netmask);
}

struct network_addr stona(char *str) {
  struct network_addr  result;
  char                addr[20];
  size_t              ip_preffix = strcspn(str, "/");
  
  strncpy(addr, str, ip_preffix);
  addr[ip_preffix] = 0;
  inet_pton(AF_INET, addr, &(result.addr));
  result.netmask = atoi(str + ip_preffix + 1);
  return result;
}
