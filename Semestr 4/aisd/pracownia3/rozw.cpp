#include <bits/stdc++.h>
using namespace std;

const int MAXP = 105;
const int MAXN = 5005;

int n, p, m;
unordered_set<int> banned;
vector<pair<int, int>> propagate;
int dp[2][1024 + 10];

inline int char_to_bit(char c) {
    return c == '.' ? 0 : 1;
}

void input() {
    scanf("%d%d%d", &n, &p, &m);
    for (int i = 0; i < p; i++) {
        char s[5];
        int value = 0, d = 1;
        for (int k = 0; k < 3; k++) {
            scanf("%s", s);
            value += (char_to_bit(s[0]) + char_to_bit(s[1]) * 2 + char_to_bit(s[2]) * 4) * d;
            d *= 8;
        }
        banned.insert(value);
    }
}

pair<int, pair<int, int>> get_pieces_values(int db, int sb) {
    int tab[5][3];
    for (int i = 0; i < 5; i++) {
        tab[i][0] = (db >> (i*2)) & 1;
        tab[i][1] = (db >> (i*2 + 1)) & 1;
        tab[i][2] = (sb >> i) & 1;
    }
    int res[3];
    for (int k = 0; k < 3; ++k) {
        int value = 0, d = 1;
        for (int i = k; i < k + 3; ++i) {
            value += (tab[i][0] + tab[i][1] * 2 + tab[i][2] * 4) * d;
            d *= 8;
        }
        res[k] = value;
    }
    return {res[0], {res[1], res[2]}};
}

int combine(int db, int sb) {
    int res = (db >> 1) & 0x155;
    for (int i = 0; i < 5; i++) {
        res |= ((sb >> i) & 1) << (2*i + 1);
    }
    return res;
}

void preproces() {
    const int db = (1<<10);     // double bar
    const int sb = (1<<5);      // single bar

    for (int db_mask = 0; db_mask < db; ++db_mask) {
        for (int sb_mask = 0; sb_mask < sb; ++sb_mask) {
            auto pieces = get_pieces_values(db_mask, sb_mask);
            if (banned.count(pieces.first) || banned.count(pieces.second.first) || banned.count(pieces.second.second)) 
                continue;
            int db2_mask = combine(db_mask, sb_mask);
            propagate.push_back({db_mask, db2_mask});
        }
    }
}

int compute_dp() {
    int K = 1;
    for (int i = 0; i < 1024; i++) {
        dp[0][i] = 1;
    }
    for (int i = 2; i < n; i++) {
        for (auto pp: propagate) {
            int p1 = pp.first, p2 = pp.second;
            dp[K][p2] += dp[K^1][p1];
            dp[K][p2] %= m;
        }
        K ^= 1;
        for (int j = 0; j < 1024; ++j) {
            dp[K][j] = 0;
        }
    }

    K ^= 1;
    int result = 0;
    for (int i = 0; i < 1024; i++) {
        result += dp[K][i];
        result %= m;
    }
    return result;
}

int main() {
    input();
    preproces();
    printf("%d\n", compute_dp());
}