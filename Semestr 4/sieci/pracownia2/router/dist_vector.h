#ifndef DIST_VECTOR_H
#define DIST_VECTOR_H

#include "linked_list.h"
#include "network_addr.h"

/* Item of the distance vector. 
 * If <<reachable>> is set to 0, then it means that the network is reachable.
 * If <<reachable>> has positive value, then it indicates that the network was
 * unreachable for <<reachable>> turns.
 */
struct vector_item {
  struct network_addr network;
  router_addr         via_ip;
  uint8_t             reachable;
};

/* Returns true if given distance vector item is connected directly, false otherwise */
bool is_connected_directly(struct vector_item item);

/* Updates the distance vector. */
void update_distance_vector(list_t *distance_vector, struct vector_item new_item);

#endif