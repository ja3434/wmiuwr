#include<bits/stdc++.h>
using namespace std;

vector<int> v;

int p(int n, int k, int m) {
  if (k == 0 && n != 0) return 0;
  if (k == 0 && n == 0) {
    for (int i = 0; i < v.size(); i++) cout << v[i] << " ";
    cout << "\n";
    return 1;
  }
  int value = 0;
  for (int i = 0; i <= min(n, m); i++) {
    v.push_back(i);
    if (i == 25) {
      cout << "ELO\n";
    }
    value += p(n - i, k - 1, i);
    v.pop_back();
  }
  return value;
}

int tab[30][30];
int cnt = 0;


int d(int n, int k) {
  if (tab[n][k] != -1) return tab[n][k];
  cout << n << " " << k << " " << ++cnt << "\n";
  if (n == 0 && k == 0) return tab[n][k] = 1;
  if (k > n || k <= 0) if (k >= 0) return tab[n][k] = 0;
  return tab[n][k] = d(n-1, k-1) + d(n-k, k);
}

// int e(int n, int k) {
//   if (n == 0 && k == 0) return tab[n][k] = 1;
//   // if (n == 0 && k > 0) return tab[n][k] = 0;
//   if (n > 0 && k <= 0) {
//     if (k >= 0) 
//       tab[n][k] = 0; 
//     return 0;
//   } 
//   if (n < 0) return 0;
//   if (tab[n][k] != -1) return tab[n][k];
//   return tab[n][k] = e(n, k-1) + e(n-k, k);
// }
// DP[i][j] = max(DP[i-1][j-1], DP[i-2][j], DP[i][j - 2], DP[i][j-2])

int main() {
  int n, k;
  cin >> n >> k;
  for (int i = 0; i < 30; i++) {
    for (int j = 0; j < 30; j++)
      tab[i][j] = -1;
  }
  cout << d(n,k) << "\n";
  // cout << p(n, k, n) << "\n";
  // cout << e(n,k) << "\n";

  for (int i = 0; i < 26; i++) {
    cout << i << ": ";
    for (int j = 0; j < 6; j++) {
      cout << tab[i][j] << " ";
    }
    cout << "\n";
  }
  // cout << p(n, k, n) << "\n";
}