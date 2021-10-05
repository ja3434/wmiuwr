#include <stdio.h>

/* Zadanie 1 */
 
void swap(long *xp, long *yp) {
  *xp = *xp + *yp; /* x+y */
  *yp = *xp - *yp; /* x+y-y = x */
  *xp = *xp - *yp; /* x+y-x = y */
}

void swap2(long *xp, long *yp) {
  long x = *xp, y = *yp;
  x = x + y, y = x - y, x = x - y;
  *xp = x, *yp = y;
}

/* Zadanie 2 */

__attribute__((noinline))
size_t my_strlen(const char *s) {
  size_t i = 0;
  while (*s++)
  i++;
  return i;
}

const char *my_index(const char *s, char v) {
  for (size_t i = 0; i < my_strlen(s); i++)
    if (s[i] == v)
      return &s[i];
  return 0;
}

/* Zadanie 3 */
void foobar(long a[], size_t n, long y, long z) {
  for (int i = 0; i < n; i++) {
    long x = y - z;
    long j = 7 * i;
    a[i] = j + x * x; 
  }
}

void foobar_decomp(long a[], size_t n, long y, long z) {
  z -= y;
  z *= z;
  for (int i = 0; i < n; i++) {
    a[i] = z;
    z += 7;
  }
}

/* Zadanie 4 */

long neigh(long a[], long n, long i, long j) {
  long ul = a[(i-1)*n + (j-1)];
  long ur = a[(i-1)*n + (j+1)];
  long dl = a[(i+1)*n - (j-1)];
  long dr = a[(i+1)*n - (j+1)];
  return ul + ur + dl + dr;
}

long neigh_better(long a[], long n, long i, long j) {
  long idx = (i-1) * n + (j-1);
  // n *= 2;
  long ul = a[idx];
  long dl = a[idx + n*2];
  idx += 2;
  long ur = a[idx];
  long dr = a[idx + n*2];
  return ul + dl + ur + dr;
}