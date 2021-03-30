#include<bits/stdc++.h>
using namespace std;
typedef long long ll;

vector<pair<int, pair<int, int>>> v;
const int MAX_LEN = 85;
int bits[100];

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie();
  int n;
  cin >> n;
  for (int i = 0; i < n; i++) {
    int d, nd;
    cin >> d >> nd;
    int k = 0;
    while (d % 2 == 0) {
      d /= 2;
      k++;
    }
    v.push_back({d, {k, nd}});
  }
  sort(v.begin(), v.end());
  int result = 0;
  
  for (int i = 0; i < n; ) {
    int h = i;
    int d = v[i].first;
    while (h < n && v[h].first == d) {
      h++;
    }
    for (int k = 0; k < MAX_LEN; k++) 
      bits[k] = 0;
    for (int j = i; j < h; ++j) {
      ll x = (ll)(1LL << v[j].second.first) * (ll)v[j].second.second;
      int k = 0;
      while (x > 0) {
        if (x % 2 == 1) {
          bits[k]++;
        }
        x /= 2;
        k++;
      }
    }

    for (int k = 0; k < MAX_LEN; k++) {
      if (bits[k] > 1) {
        bits[k + 1] += bits[k]/2;
      }
      if (bits[k] % 2 == 1) {
        result++;
      }
    }
    i = h;
  }

  cout << result << "\n";
}