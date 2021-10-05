#include <bits/stdc++.h>
using namespace std;

int n, p, m;
int banned[103][3][3];
int plane[5][10];

bool check(int k, int i, int pp) {
    for (int kk = k; kk < k + 3; kk++) {
        for (int ii = i; ii < i + 3; ii++) {
            if (plane[kk][ii] != banned[pp][kk-k][ii-i])
                return false;
        }
    }
    return true;
}

void debug(int pp) {
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            cout << ((banned[pp][i][j] == 0) ? '.' : 'x');
        }
        cout << "\n";
    }
}

void debug() {
    for (int k = 0; k < 5; ++k) {
        for (int i = 0; i < n; ++i) {
            cout << (plane[k][i] ? 'x' : '.');
        }
        cout << "\n"; 
    }
    cout << "\n";
}

int ile[1030];

int main() {
    cin >> n >> p >> m;
    for (int i = 0; i < p; i++) {
        for (int k = 0; k < 3; k++) {
            string s;
            cin >> s;
            for (int j = 0; j < 3; ++j) {
                banned[i][k][j] = (s[j] == 'x');
            }
        }
    }
    int res = 0;
    for (int mask = 0; mask < (1<<(5 * n)); mask++) {
        for (int k = 0; k < 5; ++k) {
            for (int i = 0; i < n; i++) {
                plane[k][i] = ((mask & (1 << (k * n + i))) > 0);
            }
        }
        bool dziala = true;
        for (int k = 0; k < 3; ++k) {
            for (int i = 0; i < n-2; ++i) {
                for (int j = 0; j < p; ++j) {
                    if (check(k, i, j)) {
                        dziala = false;
                        break;
                    }
                }
                if (!dziala) break;
            }
            if (!dziala) break;
        }
        if (dziala) {
            res++;
            if (res == m) {
                res = 0;
            }
            int mm = 0;
            for (int i = 0; i < 5; ++i) {
                mm += plane[i][n-2] * (1<<(i*2));
                mm += plane[i][n-1] * (1<<(i*2 + 1));
            }
            ile[mm]++;
        }
    }  
    for (int i = 0; i < 1024; ++i) {
        cout << i << ": " << ile[i] << "\n";
    }
    cout << res % m << "\n";
}