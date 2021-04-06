#include <bits/stdc++.h>
using namespace std;

const int M = (1<<20);
const size_t size = M*2 + 10;

struct query {
    char type;
    union {
        struct insert {
            int p;
            int x;
        } insert;
        struct sum {
            int from;
            int to;
        } sum;
        int del;
    };
};

struct segtreePS {
    int tree[size];

    segtreePS() {
        for (int i = 0; i < size; i++) tree[i] = 0;
    }

    void update(int where, int val) {
        where += M;
        while (where) {
            tree[where] += val;
            where /= 2;
        }
    }

    int query(int from, int to) {
        from += M;
        to += M;
        int ans = tree[from];
        if (from != to) ans += tree[to];
        while (from/2 != to/2) {
            if (from % 2 == 0)  ans += tree[from + 1];
            if (to % 2 == 1)    ans += tree[to - 1];
            to /= 2; from /= 2;
        }
        return ans;
    }
};

struct segtreeSP {
    int tree[size];

    segtreeSP() {
        for (int i = 0; i < size; i++) tree[i] = 0;
    }

    void update(int from, int to, int val) {
        from += M;
        to += M;
        tree[from] += val;
        if (from != val) tree[to] += val;
        while (from/2 != to/2) {
            if (from % 2 == 0)  tree[from + 1] += val;
            if (to % 2 == 1)    tree[to - 1] += val;
            to /= 2; from /= 2;
        }
    }

    int query(int where) {
        int ans = 0;
        where += M;
        while (where) {
            ans += tree[where];
            where /= 2;
        }
        return ans;
    }
};

vector<query> queries;
segtreeSP sptree;
map<int, int> q_to_pos;

int main() {
    int n, inserts = 0;
    scanf("%d", &n);
    for (int i = 0; i < n; ++i) {
        char c;
        query q;
        q.type = c;
        scanf(" %c", &c);
        if (c == 'D') {
            int a;
            cin >> a;
            q.del = a;
        }
        else {
            int a, b;
            cin >> a >> b;
            q.type = c;
            if (c == 'I') {
                q.insert = {a, b};
                inserts++;
            } else {
                q.sum = {a, b};
            }
        }
        queries.push_back(q);
    }
    for (int i = n-1; i > 0; i--) {
        query q = queries[i];
        if (q.type != 'I') continue;
        int addition = sptree.query(q.insert.p);
        q_to_pos[i] = addition + q.insert.p; 
    }

    for (int i = 0; i < n; i++) {
        
    }
}