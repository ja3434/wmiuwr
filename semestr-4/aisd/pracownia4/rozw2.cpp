#include <bits/stdc++.h>
using namespace std;

struct treap {
    typedef long long T;
    treap *left = nullptr;
    treap *right = nullptr;
    int rank, items = 1;
    T value;
    T sum;
    bool rev = false;

    treap(T val = T()) : rank(rand()), value(val), sum(val) {}

    inline void update() {
        if (rev) {
            swap(left, right);
            if (left)   left->rev   = !left->rev;
            if (right)  right->rev  = !right->rev;
            rev = false;
        }
    }
};

inline int items(treap *t) { return t ? t->items : 0; }
inline int sum(treap *t)   { return t ? t->sum : 0; }
inline void recalc(treap *t) { 
    t->items = items(t->left) + items(t->right) + 1; 
    t->sum   = sum(t->left) + sum(t->right) + t->value;
}

pair<treap*, treap*> split(treap *t, int k) {
    if (!t) return {nullptr, nullptr};
    t->update();
    if (items(t->left) < k) {
        auto p = split(t->right, k - items(t->left) - 1);
        t->right = p.first;
        recalc(t);
        return {t, p.second};
    }
    else {
        auto p = split(t->left, k);
        t->right = p.first;
        recalc(t);
        return {p.first, t};
    }
}

treap* merge(treap *a, treap *b) {
    if (!a) return b;
    if (!b) return a;
    a->update();
    b->update();
    if (a->rank > b->rank) {
        a->right = merge(a->right, b);
        recalc(a);
        return a;
    }
    else {
        b->left = merge(a, b->left);
        recalc(b);
        return b;
    }
}

treap::T select(treap *t, int k) {
    if (!t) return treap::T();
    t->update();
    int i = items(t->left);
    if (i == k)         return t->value;
    else if (i > k)     return select(t->left, k);
    else                return select(t->right, k - i - 1);
}

treap *insert (treap *t, treap::T val, int k) {
    auto p = split(t, k);
    return merge(merge(p.first, new treap(val)), p.second);
}

treap *erase(treap *t, int k) {
    auto p1 = split(t, k);
    auto p2 = split(p1.second, 1);
    return merge(p1.first, p2.second);
}

treap::T sum(treap *t, int l, int r) {
    auto p1 = split(t, r);
    auto p2 = split(p1.first, l);
    return sum(p2.second);
} 

void write(treap *t) {
    if (!t) return;
    t->update();
    write(t->left);
    cout << t->value << " ";
    write(t->right);
}
void destroy(treap *t) {
    if (!t) return;
    destroy(t->left);
    destroy(t->right);
    delete t;
}

treap *t = 0;

int main() {
    int n;
    scanf("%d", &n);
    for (int i = 0; i < n; i++) {
        char c;
        scanf(" %c", &c);
        if (c == 'I') {
            int p, x;
            scanf("%d%d", &p, &x);
            t = insert(t, x, p);
        }
        if (c == 'D') {
            int p;
            scanf("%d", &p);
            t = erase(t, p - 1);
        }
        if (c == 'S') {
            int l, r;
            scanf("%d%d", &l, &r);
            printf("ans: %lld\n", sum(t, l, r));
        }
        cout << "Treap:\n";
        write(t);
        cout << "\n";
    }

    destroy(t);
}