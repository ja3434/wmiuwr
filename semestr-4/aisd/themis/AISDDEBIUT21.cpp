/*
 *  Autor: Franciszek Malinka
 *  Numer indeksu: 316093
 *  Prowadzący: WJA
 */

#include <bits/stdc++.h>
using namespace std;

int main()
{
  ios_base::sync_with_stdio(false);
  cin.tie();
  int a, b;
  cin >> a >> b;
  for (int i = a; i <= b; i++)
  {
    if (i % 2021 == 0)
    {
      cout << i << " ";
    }
  }
  cout << "\n";
}