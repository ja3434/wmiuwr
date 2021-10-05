/* Projekt: Transport
 * Autor: Franciszek Malinka 316093
 */

#include "window.h"
#include <stdlib.h>
#include <strings.h>

void init_window(window_t *w, int window_size, int window_width) {
  w->ar = malloc(window_size * sizeof(char *));
  for (int i = 0; i < window_size; i++) 
    w->ar[i] = malloc(window_width * sizeof(char));
  w->uptodate = malloc(window_size);
  bzero (w->uptodate, window_size);
  w->first_pos = 0;
  w->size = window_size;
}

void destroy_window(window_t *w) {
  for (int i = 0; i < w->size; i++) 
    free(w->ar[i]);
  free(w->ar);
  free(w->uptodate);
}

void shift_while_uptodate(window_t *w) {
  while (w->uptodate[w->first_pos]) {
    w->uptodate[w->first_pos] = false;
    w->first_pos = (w->first_pos + 1) % w->size;
  }
}

void shift(window_t *w) {
  w->uptodate[w->first_pos] = false;
  w->first_pos = (w->first_pos + 1) % w->size;
}

void update(window_t *w, int pos, char *buffer, size_t buf_size) {
  pos = (w->first_pos + pos) % w->size;
  for (int i = 0; i < buf_size; i++) w->ar[pos][i] = buffer[i];
  w->uptodate[pos] = true;
}