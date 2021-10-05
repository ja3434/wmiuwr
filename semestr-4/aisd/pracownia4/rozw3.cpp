
#include <bits/stdc++.h>
using namespace std;

struct treap
{
    typedef long long T;
    treap *left = nullptr, *right = nullptr;
    
    int rank, items = 1;
    bool rev = false;
    T value, sum;
    
    treap(T val = T()) : value(val), sum(val), rank(rand()) { }
    
    inline void update()
    {
        if(rev)
        {
            swap(left, right);
            if(left) left->rev = !left->rev;
            if(right) right->rev = !right->rev;
            rev = false;
        }
    }
};

inline int items(treap *t) { return t ? t->items : 0; }
inline treap::T sum(treap *t) { return t ? t->sum : 0; }
inline void recalc(treap *t) { 
    t->items = items(t->left) + items(t->right) + 1; 
    t->sum   = sum(t->left) + sum(t->right) + t->value;    
}

pair<treap*, treap*> split(treap *t, int k) //dzieli na prefiks dlugosci k i reszte
{
    if(!t) return make_pair(nullptr, nullptr);
    //t = new treap(*t); //odkomentowac zeby zrobic strukture trwala
    t->update();
    if(items(t->left) < k)
    {
        auto p = split(t->right, k - items(t->left) - 1);
        t->right = p.first;
        recalc(t);
        return make_pair(t, p.second);
    }
    else
    {
        auto p = split(t->left, k);
        t->left = p.second;
        recalc(t);
        return make_pair(p.first, t);
    }
}

treap* merge(treap *a, treap *b)
{
    if(!a) return b;
    if(!b) return a;
    a->update();
    b->update();
    if(a->rank > b->rank) {
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

treap::T select(treap *t, int k) //zwraca k-ty element
{
    if(!t) return treap::T();
    t->update();
    int i = items(t->left);
    if(i == k) return t->value;
    if(i > k) return select(t->left, k);
    return select(t->right, k - i - 1);
}

treap* insert(treap *t, treap::T val, int k) //wstaw val na pozycje k (liczac od 0)
{
    auto p = split(t, k);
    return merge(merge(p.first, new treap(val)), p.second);
}
void write(treap *t)
{
    if(!t) return;
    t->update();
    write(t->left);
    cout << "(" << t->value << ", " << t->sum << ") ";
    write(t->right);
}

treap* erase(treap *t, int k)
{
    auto p1 = split(t, k);
    auto p2 = split(p1.second, 1);
    return merge(p1.first, p2.second);
}

treap* reverse(treap *t, int a, int b) //odwroc przedzial <a, b)
{
    auto p1 = split(t, b);
    auto p2 = split(p1.first, a);
    if(p2.second) p2.second->rev = !p2.second->rev;
    return merge(merge(p2.first, p2.second), p1.second);
}

treap::T sum(treap* t, int l, int r) {
    auto p1 = split(t, r);
    auto p2 = split(p1.first, l);
    treap::T ret = sum(p2.second);
    merge(merge(p2.first, p2.second), p1.second);
    return ret;
}

treap *root = 0;

int main() {
    int n;
    scanf("%d", &n);
    for (int i = 0; i < n; i++) {
        char c;
        scanf(" %c", &c);
        if (c == 'I') {
            int p, x;
            scanf("%d%d", &p, &x);
            root = insert(root, x, p);
        }
        if (c == 'D') {
            int p;
            scanf("%d", &p);
            root = erase(root, p - 1);
        }
        if (c == 'S') {
            int l, r;
            scanf("%d%d", &l, &r);
            printf("%lld\n", sum(root, l - 1, r));
        }
        // cout << "Treap:\n";
        // write(root);
        // cout << "\n";
    }

}