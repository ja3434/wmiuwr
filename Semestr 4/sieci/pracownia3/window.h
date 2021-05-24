#ifndef WINDOW_H
#define WINDOW_H

#include <stdbool.h>
#include <stddef.h>

typedef struct {
  char **ar;
  bool *uptodate;
  int size;
  int first_pos;
} window_t;

void init_window(window_t *w, int window_size, int window_width);

void destroy_window(window_t *w);

void shift_while_uptodate(window_t *w);

void shift(window_t *w);

void update(window_t *w, int pos, char *buffer, size_t buf_size);

#endif