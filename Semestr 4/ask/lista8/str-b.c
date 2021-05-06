#include <stdlib.h>
#include <string.h>

char *somestr(void) {
  char *buf = malloc(sizeof("Hello, world!"));
  strcpy(buf, "Hello, world!");  
  return buf;
}

