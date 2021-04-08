#include <bits/stdc++.h>
using namespace std;
typedef long long ll;

struct insert_list {
    vector<int> v;
    
    insert_list() {
    }

    void insert(int p, int val) {
        assert(p <= v.size());
        assert(p >= 0);
        vector<int> temp;
        for (int i = 0; i < p; i++) {
            temp.push_back(v[i]);
        }
        temp.push_back(val);
        for (int i = p; i < v.size(); i++) {
            temp.push_back(v[i]);
        }
        v = temp;
    }

    void erase(int p) {
        assert(p <= v.size());
        assert(p >= 1);
        vector<int> temp;
        for (int i = 0; i < p-1; i++) {
            temp.push_back(v[i]);
        }
        for (int i = p; i < v.size(); i++) {
            temp.push_back(v[i]);
        }
        v = temp;
    }

    ll sum(int l, int r) {
        ll ans = 0;
        for (int i = l-1; i < r; i++) {
            ans += v[i];
        }
        return ans;
    }
};  

insert_list v;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie();
    int n;
    cin >> n;
    for (int i = 0; i < n; i++) {
        char c;
        cin >> c;
        if (c == 'D') {
            int a;
            cin >> a;
            v.erase(a);
        }
        else {
            int a, b;
            cin >> a >> b;
            if (c == 'I') v.insert(a, b);
            else cout << v.sum(a,b) << "\n";
        }
    }
}