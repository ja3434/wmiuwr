#include<bits/stdc++.h>
using namespace std;
typedef unsigned long long ll;

vector<pair<int, ll>> v;

int main() {
    int n;
    scanf("%d", &n);
    for (int i = 0; i < n; i++) {
        int d, nd, k = 0;
        scanf("%d %d", &d, &nd);
        while (d % 2 == 0) {
            k++;
            d /= 2;
        }
        v.push_back({d, (ll)(1LL<<k) * (ll)nd});
    }
    sort(v.begin(), v.end());
    int result = 0;
    for (int i = 0; i < n; ) {
        int j = i;
        int cur = v[i].first;
        ll count = 0;
        while (j < n && v[j].first == cur) {
            count += v[j].second;
            ++j;
        }
        result += __builtin_popcountll(count);
        i = j;
    }
    cout << result << "\n";
}