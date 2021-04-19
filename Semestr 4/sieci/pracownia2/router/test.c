#include "linked_list.h"
#include <stdlib.h>
#include <stdio.h>

/* Prints the list of ints to stdio */
void print_list(list_t list) {
  printf("List: ");
  reset(&list);
  while (list.it != NULL) {
    printf("%d, ", *(int *)(list.it->data));
    iterate(&list);
  }
  printf("\n");
  reset(&list);
}

int main() {
  int n;
  scanf("%d", &n);
  list_t list = create_list();

  for (int i = 0; i < n; i++) {
    int t;
    scanf("%d", &t);
    // insert
    if (t == 0) {
      int val = 0;
      scanf("%d", &val);
      insert(&list, &val, sizeof(int));
    }
    if (t == 1) {
      erase(&list);
    }
    if (t == 2) {
      print_list(list);
    }
  }

  free_list(&list);
}