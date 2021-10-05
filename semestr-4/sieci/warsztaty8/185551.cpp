#include <bits/stdc++.h>
using namespace std;
typedef long long ll;
#define pb push_back
#define st first
#define nd second

const int N = 1000007;

map<ll, int> M;
ll tab[N];
vector <ll> v;
queue <pair<ll, int>> q;

int main () {
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    ll n, a=-1, b=0;
    M[0]=1;
    cin>>n;
    for(int i=0; i<n; i++) {
        cin>>tab[i];
    }
    sort(tab, tab+n);
    for(int i=0; i<n; i++) {
        if(a!=tab[i]) b=0;
        a=tab[i];
        if(M[a]-b==0) {
            for(auto u : M) {
                if(u.nd>0) q.push({u.st+a, u.nd});
            }
            while(!q.empty()) M[q.front().st]+=q.front().nd, q.pop();
            v.pb(a);
        }
        b++;
    }
    cout<<v.size()<<"\n";
    for(auto u : v) {
        cout<<u<<" ";
    }
}
