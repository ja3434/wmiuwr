#include "CORDICtable.c"
#include <iostream>
// angle is radians multiplied by CORDIC multiplication factor M
// modulus can be set to CORDIC inverse gain 1/F to avoid post-division
void CORDICsincos(int a, int m, int *s, int *c)
{
  int k, tx, x = m, y = 0, z = a, fl = 0;
  if (z > +CORDIC_HALFPI)
  {
    fl = +1;
    z = (+CORDIC_PI) - z;
  }
  else if (z < -CORDIC_HALFPI)
  {
    fl = +1;
    z = (-CORDIC_PI) - z;
  }
  for (k = 0; k < CORDIC_MAXITER; k++)
  {
    std::cout << x << " " << y << " " << z << "\n";
    tx = x;
    if (z >= 0)
    {
      x -= (y >> k);
      y += (tx >> k);
      z -= CORDIC_ZTBL[k];
    }
    else
    {
      x += (y >> k);
      y -= (tx >> k);
      z += CORDIC_ZTBL[k];
    }
  }
  if (fl)
    x = -x;
  *c = x; // m*cos(a) multiplied by gain F and factor M
  *s = y; // m*sin(a) multiplied by gain F and factor M
}

int main()
{
  double x;
  std::cin >> x;
  int sinus, cosinus;
  CORDICsincos(x * CORDIC_MUL, CORDIC_1F, &sinus, &cosinus);
  std::cout << sinus << " " << cosinus << "\n";
  std::cout << (double)sinus / (double)CORDIC_MUL << " " << (double)cosinus / (double)CORDIC_MUL << "\n";
}