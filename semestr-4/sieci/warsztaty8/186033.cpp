#include <bits/stdc++.h>

using namespace std;

#define st first
#define nd second
#define pb push_back
#define sz(x) (int)(x).size()
#define ll long long
ll mod=1000000007;
int inf=1000000007;
ll infl=1000000000000000007;

int seg[4*600007];
int lazy[4*600007];
int pot=1;

void push(int v,int sz)
{
    if(lazy[v]!=0)
    {
        seg[2*v]=sz/2*lazy[v];
        lazy[2*v]=lazy[v];
        seg[2*v+1]=sz/2*lazy[v];
        lazy[2*v+1]=lazy[v];
    }
    lazy[v]=0;
}

void ins(int u,int a,int b,int l,int r,int v)
{
    if(a<=l&&b>=r)
    {
        lazy[u]=v;
        seg[u]=(r-l+1)*v;
        return ;
    }
    if(l>b||r<a) return ;
    push(u,r-l+1);
    ins(2*u,a,b,l,(l+r)/2,v);
    ins(2*u+1,a,b,(l+r)/2+1,r,v);
    seg[u]=seg[2*u]+seg[2*u+1];
}

int que(int u,int a,int b,int l,int r)
{
    if(a<=l&&b>=r) return seg[u];
    if(l>b||r<a) return 0;
    push(u,r-l+1);
    return que(2*u,a,b,l,(l+r)/2)+que(2*u+1,a,b,(l+r)/2+1,r);
}

unordered_map<int,int>mapa;
int l[100007];
int r[100007];

int main()
{
    ios_base::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,h,ans=2;
    cin>>n>>h;
    set<int>S;
    S.insert(1);
    S.insert(h);
    for(int i=1;i<=n;i++)
    {
        cin>>l[i]>>r[i];
        l[i]++;
        if(l[i]!=h) S.insert(l[i]+1);
        if(l[i]!=1) S.insert(l[i]-1);
        if(r[i]!=h) S.insert(r[i]+1);
        if(r[i]!=1) S.insert(r[i]-1);
        S.insert(l[i]);
        S.insert(r[i]);
    }
    int it=0;
    mapa.reserve(sz(S)+2);
    for(auto x:S) mapa[x]=++it;
    for(int i=1;i<=n;i++)
    {
        l[i]=mapa[l[i]];
        r[i]=mapa[r[i]];
    }
    while(pot<it) pot*=2;
    ins(1,1,it,1,pot,2);
    for(int i=1;i<=n;i++)
    {
        ins(1,l[i],r[i],1,pot,1);
        if(seg[1]==it)
        {
            ans+=2;
            ins(1,1,l[i]-1,1,pot,2);
            ins(1,r[i]+1,it,1,pot,2);
        }
    }
    cout<<ans;

    return 0;
}
