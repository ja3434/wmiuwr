#ifndef DIST_VECTOR_H
#define DIST_VECTOR_H

#include "linked_list.h"
#include "network_addr.h"
#include "config.h"

/* Item of the distance vector. 
 * If <<reachable>> is set to 0, then it means that the network is reachable.
 * If <<reachable>> has positive value, then it indicates that the network was
 * unreachable for <<reachable>> turns.
 */
struct vector_item {
  struct network_addr network;
  struct in_addr      via_ip;
  uint16_t            distance;
  uint8_t             reachable;
  bool                is_connected_directly;
};

/* Initis distance vector with given neighbours array. */
void init_dv(list_t *dv, int n_cnt, struct network_addr *neighbours);

/* Returns true if given distance vector item is connected directly, false otherwise. */
bool is_connected_directly(struct vector_item item);

/* Updates the distance vector. */
void update_dv_new_item(list_t *distance_vector, struct vector_item new_item);

/* Updates reachabilities. */
void update_dv_reachability(list_t *distance_vector);

/* Print distance vector. */
void print_dv(list_t *distance_vector);

#endif