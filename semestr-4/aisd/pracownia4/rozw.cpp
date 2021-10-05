#include <bits/stdc++.h>
using namespace std;
typedef long long ll;

const int K = 20;
const int M = (1<<K);
const size_t tree_size = M*2 + 10;

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
    } info;
};

struct kox_set {
    ll tree[tree_size];

    kox_set() {
        for (int i = 0; i < tree_size; i++) tree[i] = 0;
    }

    void add(int val) {
        update(val, 1);
    }

    void del(int val) {
        update(val, -1);
    }

    void update(int where, int val) {
        where += M;
        while (where) {
            tree[where] += val;
            where /= 2;
        }
    }

    ll sum(int from, int to) {
        from += M;
        to += M;
        ll ans = tree[from];
        if (from != to) ans += tree[to];
        while (from/2 != to/2) {
            if (from % 2 == 0)  ans += tree[from + 1];
            if (to % 2 == 1)    ans += tree[to - 1];
            to /= 2; from /= 2;
        }
        return ans;
    }

    int kth_elem(int k) {
        int where = 1;
        while (where < M) {
            where *= 2;
            if (tree[where] < k) {
                k -= tree[where];
                where += 1;
            } 
        }
        return where - M;
    }

    void fill(int value) {
        for (int i = 0; i < M; i++) {
            tree[i + M] = value;
        }
        for (int d = K-1; d >= 0; d--) {
            int maks = (1<<d);
            for (int i = 0; i < maks; i++) {
                int ind = i + maks;
                tree[ind] = tree[ind*2] + tree[ind*2 + 1];
            }
        }
    }
};

vector<query> queries;
map<int, int> q_to_pos;
kox_set secik;
kox_set pstree;


int main() {
    int n, inserts = 0;
    scanf("%d", &n);
    for (int i = 0; i < n; ++i) {
        char c;
        scanf(" %c", &c);
        query q;
        q.type = c;
        if (c == 'D') {
            int a;
            scanf("%d", &a);
            pstree.add(a);
            q.info.del = a;
        }
        else {
            int a, b;
            scanf("%d%d", &a, &b);
            q.type = c;
            if (c == 'I') {
                q.info.insert = {a, b};
                inserts++;
            } else {
                q.info.sum = {a, b};
            }
        }
        queries.push_back(q);
    }

    secik.fill(1);
    for (int i = n-1; i >= 0; i--) {
        query q = queries[i];
        if (q.type == 'D') {
            pstree.del(q.info.del);
        }
        if (q.type == 'I') {
            int offset = pstree.sum(0, q.info.insert.p);
            int kth = secik.kth_elem(q.info.insert.p + offset + 1);
            secik.del(kth);
            q_to_pos[i] = kth;
            cout << q.info.insert.p << " " << offset << "\n";
            cout << i << ": " << q_to_pos[i] << "\n";
        }
    }
    secik.fill(0);
    pstree.fill(0);

    for (int i = 0; i < n; i++) {
        query q = queries[i];
        if (q.type == 'I') {
            secik.add(q_to_pos[i]);
            pstree.update(q_to_pos[i], q.info.insert.x);
            // cout << "Inserting " << q.info.insert.x << " to " << q_to_pos[i] << "\n";
        }
        if (q.type == 'D') {
            int pos = secik.kth_elem(q.info.del);
            // cout << "kth: " << q.info.del << " " << pos << "\n";
            secik.del(pos);
            pstree.update(pos, -pstree.tree[pos + M]);
        }
        if (q.type == 'S') {
            int from = secik.kth_elem(q.info.sum.from);
            int to = secik.kth_elem(q.info.sum.to);
            printf("%lld\n", pstree.sum(from, to));
        }   
    }
}