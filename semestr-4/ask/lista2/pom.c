#include <stdint.h>
#include <stdio.h>
#include <limits.h>

char* utb(uint32_t x) {
  static char rep[36];
  int cnt = 34;
  for (int i = 0; i < 32; i += 1) {
    if (i > 0 && i % 8 == 0) {
      rep[cnt] = ' ';
      cnt -= 1;
    }
    rep[cnt] = (x & 1) + '0';
    cnt -= 1;
    x >>= 1;
  }
  rep[35] = '\0';
  return rep;
}

void pb(uint32_t x) {
  printf("%s    : %d\n", utb(x), x);
}

// int main() {
//     /* Zadanie 1 */

//     int32_t x;
//     x = (1<<31);
//     printf("%d, %d, %d %d\n", x, (x > 0), x-1, (x - 1 < 0));
// }

int main() {
    /* Zadanie 1 */
    int32_t x;
    scanf("%d", &x);
    printf("%d %d\n", x*x, INT_MIN);
}