#ifndef LINKED_LIST_H
#define LINKED_LIST_H

#include <stddef.h>

typedef struct node {
  void *data;
  struct node *next;
} node_t;


typedef struct list_t {
  node_t *head;
  node_t *it;
  node_t *prev_it;
} list_t;

/* Creates an empty list. */
list_t create_list();

/* Insert a new node in the begining of a list. */
void insert(list_t *list, void *data, size_t data_size);

/* Erases first node from the list. */
void erase(list_t *list);

/* Erases element under iterator and sets iterator to the next one. */
void erase_it(list_t *list);

/* Moves iterator one step. */
void iterate(list_t *list);

/* Resets the iterator. 
 * Should execute the function after if you want to itarate unless you didnt insert or erase anything from the list. 
 */
void reset(list_t *list);

/* Deletes the whole list. */
void free_list(list_t *list);


#endif