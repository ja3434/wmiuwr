#include "linked_list.h"
#include <stdlib.h>
#include <stdint.h>

node_t *_next(node_t *node) {
  return (node == NULL) ? NULL : node->next;
}

void _insert(node_t **head, void *data, size_t data_size) {
  node_t *new_node = (node_t *)malloc(sizeof(node_t));
  new_node->data = malloc(data_size);  
  for (int i = 0; i < data_size; i++)
    *(uint8_t *)(new_node->data + i) = *(uint8_t *)(data + i);
  new_node->next = *head;
  *head = new_node;
}

void _free_node(node_t *node) {
  free(node->data);
  free(node);
}

void _erase(node_t **head) {
  node_t *next_node = _next(*head);
  _free_node(*head);
  *head = next_node;
}

void _free_list(node_t *head) {
  if (head == NULL) return;
  _free_list(head->next);
  _free_node(head);
}

list_t create_list() {
  list_t ret;
  ret.head = NULL;
  ret.it = NULL;
  return ret;
}

void insert(list_t *list, void *data, size_t data_size) {
  _insert(&list->head, data, data_size);
}

void erase(list_t *list) {
  _erase(&list->head);
}

void erase_it(list_t *list) {
  if(list->it == NULL) return;
  if(list->prev_it == NULL) {
    erase(list);
    reset(list);
    return;
  }
  list->prev_it->next = _next(list->it);
  _free_node(list->it);
  list->it = list->prev_it->next;
}

void iterate(list_t *list) {
  list->prev_it = list->it;
  list->it = _next(list->it);
}

void reset(list_t *list) {
  list->prev_it = NULL;
  list->it = list->head;
}

void free_list(list_t *list) {
  _free_list(list->head);
}