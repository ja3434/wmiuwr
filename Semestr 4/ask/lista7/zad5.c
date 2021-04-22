#include <stdio.h>

typedef struct A {
  long u[2];
  long *v;
} SA;

typedef struct B {
  long p[2];
  long q;
} SB;

SB eval(SA s);
long wrap(long x, long y, long z);

SB eval_decoded(SA a) {
  SB ret;
  ret.p[0] = a.u[1] * (*a.v);
  ret.p[1] = a.u[0] - (*a.v);
  ret.q = a.u[0] - a.u[1];
  return ret;
}

long wrap_decoded(long x, long y, long z) {
  SA a;
  a.v = &z;
  a.u[0] = x;
  a.u[1] = y;
  SB b = eval_decoded(a);
  long result = (b.p[1] + b.p[0]) * b.q;
  return result;
}

int main() {
  printf("%ld\n", wrap(15, 16, 17));
  printf("%ld\n", wrap_decoded(15, 16, 17));
  return 0;
}