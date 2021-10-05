#include <bits/stdc++.h>
using namespace std;

int fast_pow(int a, int b, int m)
{
  if (b == 0)
  {
    return 1;
  }
  long long p = fast_pow(a, b / 2, m);
  p = (p * p) % m;
  if (b % 2 == 0)
    return (int)p;
  return (p * (long long)a) % m;
}

int main()
{
  ios_base::sync_with_stdio(false);
  cin.tie();
  int t;
  cin >> t;
  while (t--)
  {
    int a, b, m;
    cin >> a >> b >> m;
    cout << fast_pow(a, b, m) << "\n";
  }
}