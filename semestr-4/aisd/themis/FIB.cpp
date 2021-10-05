#include <bits/stdc++.h>
using namespace std;
typedef long long ll;

class matrix
{
public:
  ll a, b, c, d;
  static ll m;

  matrix(ll _a = 0, ll _b = 0, ll _c = 0, ll _d = 0) : a(_a), b(_b), c(_c), d(_d) {}

  matrix operator*(const matrix &M) const
  {
    matrix res;
    res.a = (a * M.a + b * M.c) % m;
    res.b = (a * M.b + b * M.d) % m;
    res.c = (c * M.a + d * M.c) % m;
    res.d = (c * M.b + d * M.d) % m;
    return res;
  }
};

ll matrix::m = 1;

matrix fast_pow(matrix M, int w)
{
  matrix res(1, 0, 0, 1);
  while (w)
  {
    if (w % 2 == 1)
      res = res * M;
    M = M * M;
    w >>= 1;
  }
  return res;
}

void solve()
{
  int n, m;
  cin >> n >> m;
  matrix M(0, 1, 1, 1);
  matrix::m = m;
  cout << fast_pow(M, n + 1).a << "\n";
}

int main()
{
  ios_base::sync_with_stdio(false);
  cin.tie();
  int t;
  cin >> t;
  while (t--)
  {
    solve();
  }
}