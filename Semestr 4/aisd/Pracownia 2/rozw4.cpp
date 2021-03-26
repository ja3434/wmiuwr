#include<bits/stdc++.h>
using namespace std;

const int MAX_SUM = 1e6, MAXN = 2004;
int n;
int dp[2][MAX_SUM + 10], H[MAXN];

int main() {
    scanf("%d", &n);
    for (int i = 0; i < n; ++i) {
        scanf("%d", &H[i]);
    }
    
    sort(H, H + n);

    int sum = 0, K = 0;
    for (int i = 0; i < n; ++i) {
        int h = H[i];
        for (int i = 0; i <= min(sum, MAX_SUM); i++) 
            dp[K^1][i] = dp[K][i];
            
        for (int i = 0; i <= min(sum, MAX_SUM); i++) {
            if (i != 0 && dp[K][i] == 0) continue;

            int left = abs(i - h), aux = i-h >= 0 ? 0 : h-i;
            if (left <= MAX_SUM) {
                dp[K^1][left] = max(dp[K^1][left], dp[K][i] + aux);
            }
            int right = i + h;
            if (right <= MAX_SUM) {
                dp[K^1][right] = max(dp[K^1][right], dp[K][i] + h);
            }
        }
        
        K ^= 1;            
        sum += h;
    }
    if (dp[K][0] != 0) {
        printf("TAK\n%d\n", dp[K][0]);
    }
    else {
        int res = 0;
        for (int i = 1; i <= MAX_SUM; i++) {
            if (dp[K][i] != i && dp[K][i]) {
                res = i;
                break;
            }
        }
        printf("NIE\n%d\n", res);
    }
}