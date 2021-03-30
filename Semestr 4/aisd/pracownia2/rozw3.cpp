#include<bits/stdc++.h>
using namespace std;

#define RIGHT 0
#define LEFT 1

const int MAXN = 2e3 + 10;
const int M = 5e5 + 10;

int n, H[MAXN], dp[2][M*2];
bool vis[2][M*2], both[2][M*2];

int get_val()

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie();
    cin >> n;
    for (int i = 0; i < n; i++) {
        cin >> H[i];
    }

    int sum = 0, K = 0;
    vis[K^1][0] = true;
    for (int i = 0; i < n; i++) {
        int h = H[i];
        for (int cur = -sum; cur <= sum; ++cur) {
            vis[K][cur + M] |= vis[K^1][cur + M];
            both[K][cur + M] |= both[K^1][cur + M];
            dp[K][cur + M] = max({dp[K][cur + M], dp[K^1][cur + M]});
            if (vis[K][cur + M]) {
                int val = dp[K][cur + M];
                int left = cur + M - h;
                int right = cur + M + h;

                if (cur - h >= 0) {
                    both[K][right] = true;
                }
                vis[K][right] = true;
                dp[K][right] = max({dp[K][right], dp[K^1][right], dp[K^1][right] + h});

                if (cur + h <= 0) {
                    both[K][left]= true;
                }
                vis[K][left] = true;
                dp[K][left] = max({dp[K][left], dp[K^1][left], dp[K^1][left] + h});
            }
        }
        K^=1;
        for (int cur = -sum; cur <= sum; ++cur) {
            dp[K][cur + M] = 0;
            vis[K][cur + M] = 0;
            both[K][cur + M] = 0;
        }
        sum += h;
    }
    K^=1;
    if (both[K][M]) {
        cout << "TAK\n";
        cout << dp[K][M] << "\n";
    } else {
        cout << "NIE\n";
        int best = -sum;
        for (int cur = -sum ; cur <= sum; ++cur) {
            if (both[cur + M] && abs(cur) < abs(best)) {
                best = cur;
            }
        }
        cout << abs(best) << "\n";
    }
}