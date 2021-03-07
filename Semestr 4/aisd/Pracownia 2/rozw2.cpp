#include <bits/stdc++.h>
using namespace std;

const int MAX_SUM = 5e5;

int t[2][MAX_SUM * 2 + 10];
int H[2003];
uint8_t eligible[2][MAX_SUM * 2 + 10];     // 0 - not used, 1 - only st, 2 - only nd, 3 - both

int main() {
    int n, sum = 0, which = 0;
    scanf("%d", &n);
    for (int i = 0; i < n; i++)
        scanf("%d", &H[i]);
    sort(H, H + n);

    for (int i = 0; i < n; i++) {
        // cout << i << "\n";
        int h = H[i], *prev = t[which], *cur = t[which ^ 1];
        uint8_t *pe = eligible[which], *ce = eligible[which ^ 1];

        for (int dif = -sum; dif <= sum; ++dif) {
            int aux = 0;
            // cout << (int)pe[dif + MAX_SUM] << "\n";
            
            if (abs(dif) > MAX_SUM || (pe[dif + MAX_SUM] == 0 && dif != 0)) continue;
            
            if (dif + h <= MAX_SUM) {
                if (dif >= 0) {
                    aux = h;
                } else if (dif + h > 0) {
                    aux = dif + h;
                }
                int idx = dif + h + MAX_SUM;

                cur[idx] = max({cur[idx], prev[idx], prev[idx - h] + aux});
                ce[idx] |= pe[dif + MAX_SUM] | 1;
                // cout << "> " << idx - MAX_SUM << " " << cur[idx] << " " << (int)eligible[idx] << "\n";
            }

            if (dif - h >= -MAX_SUM) {
                aux = 0;
                if (dif <= 0) {
                    aux = h;
                } else if (dif - h < 0) {
                    aux = h - dif;
                }
                int idx = dif - h + MAX_SUM;
                cur[idx] = max({cur[idx], prev[idx], prev[idx + h] + aux});
                ce[idx] |= pe[dif + MAX_SUM] | 2;
                // cout << ">> " << idx - MAX_SUM << " " << cur[idx] << " " << (int)eligible[idx] << "\n";
            }
        }
        sum += h;
        which ^= 1;
        // for (int dif = -sum; dif <= sum; ++dif) {
        //     cout << dif << " " << " " << (int)ce[dif + MAX_SUM] << " " << cur[dif + MAX_SUM] << "\n";
        // }
        // printf("-----\n");
    }
    if (eligible[which][MAX_SUM] == 3) {
        printf("TAK\n%d\n", t[which][MAX_SUM]);
    } else {
        int mini = 1e9;
        for (int i = -MAX_SUM; i <= MAX_SUM; i++) {
            if (eligible[which][i + MAX_SUM] == 3)
                mini = min(mini, abs(i));
        }
        printf("NIE\n%d\n", mini);
    }
}