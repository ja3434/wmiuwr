#include "dist_vector.h"

bool is_connected_directly(struct vector_item item) {
  return (get_network_address(item.network).s_addr == 
    get_network_address(item.via_ip).s_addr);
}

void update_distance_vector(list_t *distance_vector, struct vector_item new_item) {}