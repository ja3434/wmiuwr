#include <stdint.h>
#include <stdio.h>

int main()
{
  int x;
  short y;
  x = -10;
  y = (short)x;
  printf("%d %hd", x, y);
}