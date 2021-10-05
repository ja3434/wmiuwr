#include <bits/stdc++.h>
using namespace std;

const int MAX_SUM = 1e6;
const int N = 2e3 + 10;

unordered_map<int, int> sums;
vector<pair<int, int>> v;

int main() {
    int n;
    scanf("%d", &n);
    sums[0] = 0;
    for (int i = 0; i < n; i++) {
        int h;
        scanf("%d", &h);
        v.clear();
        for (auto kv: sums) {
            v.push_back(kv);
        }

        for (auto kv: v) {
            int dif = kv.first, best = kv.second;
            cout << dif << " " << best << "\n";
            int aux = 0;
            if (dif >= 0) {
                aux = h;
            } else if (dif + h > 0) {
                aux = dif + h;
            }

            cout << ">aux: " << aux << " ";
            sums[dif + h] = max(sums[dif + h], best + aux);
            aux = 0;
            if (dif <= 0) {
                aux = h;
            } else if (dif - h < 0) {
                aux = h - dif;
            }
            cout << aux << "\n";
            sums[dif - h] = max(sums[dif - h], best + aux);
        }
        cout << "---\n";
    }
    for (auto kv: sums) {
        printf("%d %d\n", kv.first, kv.second);
    }

    if (sums[0] != 0) {
        printf("TAK\n%d\n", sums[0]);
    } else {
        int mini = 1e9;
        sums.erase(0);
        for (auto kv: sums) {
            mini = min(mini, abs(kv.first));
        }
        printf("NIE\n%d\n", mini);
    }
}