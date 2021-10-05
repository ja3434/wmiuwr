/*
 *  Program:  router
 *  Autor:    Franciszek Malinka, 316093
 */

#include "dist_vector.h"
#include <stdio.h>
#include <time.h>
#include <string.h>

bool is_connected_directly(struct vector_item item) {
  return item.is_connected_directly;
}

bool is_reachable(struct vector_item item) {
  return (item.distance < INFINITY_DIST);
}

void init_dv(list_t *dv, int n_cnt, struct network_addr *neighbours) {
  for (int i = 0; i < n_cnt; i++) {
    struct vector_item new_item;
    new_item.network = neighbours[i];
    new_item.distance = INFINITY_DIST;
    new_item.is_connected_directly = true;
    insert(dv, &new_item, sizeof(new_item));
  }
}

void update_dv_reachability(list_t *distance_vector) {
  reset(distance_vector);
  while (distance_vector->it != NULL) {
    struct vector_item *current = (struct vector_item *)distance_vector->it->data;
    if(++current->reachable > REACHABILITY_WAIT_TIME) {
      if (current->distance >= INFINITY_DIST) {
        if (!is_connected_directly(*current)) {
          erase_it(distance_vector);
        }
      } else {
        current->distance = INFINITY_DIST;
        current->reachable = 0;
      }
    }
    iterate(distance_vector);
  }
}

void update_dv_new_item(list_t *distance_vector, struct vector_item new_item) {
  bool new_entry = true;
  reset(distance_vector);
  while (distance_vector->it != NULL) {
    struct vector_item *current = (struct vector_item *)distance_vector->it->data;

    /* If the network is already in the distance vector, then we possibly want to change it:
     *  - if the new item has better distance than the previous one, then we just want to change it no matter what,
     *  - if the new item has the same via ip, then we want to check two things:
     *     - if new item has infinity dist, then we want to set infinity (if it wasn't set, then we want to change reachable to 0)
     *     - if new item has < inf dist, then we want to change reachable to 0 and set our dist accordingly.
     *  - else we ignore the entry.
     */
    if (get_network_address(current->network).s_addr == get_network_address(new_item.network).s_addr) {
      if (current->distance > new_item.distance) {
        *current = new_item;
        current->reachable = 0;
      } else if(current->via_ip.s_addr == new_item.via_ip.s_addr) {
        if (new_item.distance >= INFINITY_DIST) {
          if (current->distance < INFINITY_DIST) {
            current->distance = INFINITY_DIST;
            current->reachable = 0;
          }
        } else {
          current->distance = new_item.distance;
          current->reachable = 0;
        }
      }
      new_entry = false;
    }

    iterate(distance_vector);
  }

  if (new_entry && new_item.reachable < INFINITY_DIST) {
    insert(distance_vector, &new_item, sizeof(new_item));
  }
}

void print_dv(list_t *distance_vector) {
  time_t rawtime;
  struct tm * timeinfo;

  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  char t[100];
  strcpy(t, asctime(timeinfo));
  t[strlen(t) - 1] = 0;
  printf("Distance vector [%s]:\n", t);
  reset(distance_vector);
  while (distance_vector->it != NULL) {
    char addr[20], via_addr[20];
    struct vector_item current  = *(struct vector_item *)distance_vector->it->data;
    struct in_addr net_addr     = get_network_address(current.network);
    inet_ntop(AF_INET, &net_addr, addr, sizeof(addr));
    printf("%s/%d ", addr, current.network.netmask);
    
    if (is_reachable(current))          printf("distance %d ", current.distance);
    else                                printf("unreachable ");

    inet_ntop(AF_INET, &current.via_ip, via_addr, sizeof(via_addr));
    if (is_connected_directly(current)) printf("connected directly\n");
    else                                printf("via %s\n", via_addr);

    iterate(distance_vector);
  }
  printf("\n");
}