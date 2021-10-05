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

int a[77][77];
int id[77][77];
int id1[77][77];
int id2[77][77];
set<int>G[15007];
int cap1[3507][3507];
unordered_map<int,int>cap[15007];
int o[15007];
bool odw[15007];
int s=1,t;
char ans[77][77][3][3];

bool dfs(int v)
{
    //cout<<v<<endl;
    odw[v]=1;
    if(v==t) return 1;
    for(auto u:G[v])
    {
        if(odw[u]) continue;
        o[u]=v;
        if(dfs(u)) return 1;
    }
    return 0;
}

int flow()
{
    int F=0;
    while(dfs(s))
    {
        memset(odw,0,sizeof odw);
        int p=t,f=inf;
        while(p!=s)
        {
            if(o[p]<=3500&&p<=3500) f=min(f,cap1[o[p]][p]);
            else f=min(f,cap[o[p]][p]);
            p=o[p];
        }
        F+=f;
        p=t;
        while(p!=s)
        {
            if(o[p]<=3500&&p<=3500)
            {
                cap1[o[p]][p]-=f;
                if(cap1[o[p]][p]==0) G[o[p]].erase(p);
                cap1[p][o[p]]+=f;
            }
            else
            {
                cap[o[p]][p]-=f;
                if(cap[o[p]][p]==0) G[o[p]].erase(p);
                cap[p][o[p]]+=f;
            }
            G[p].insert(o[p]);
            p=o[p];
        }
    }
    return F;
}

void gg()
{
    cout<<"NIE";
    exit(0);
}

void edge(int u,int v,int c)
{
    G[u].insert(v);
    if(u<=3500&&v<=3500) cap1[u][v]=c;
    else cap[u][v]=c;
}


void connect(int x,int y,int x1,int y1)
{
    if(a[x][y]==2)
    {
        if(a[x1][y1]==2)
        {
            if(x==x1) edge(id2[x][y],id2[x1][y1],1);
            else edge(id1[x][y],id1[x1][y1],1);
        }
        else
        {
            if(x==x1) edge(id2[x][y],id[x1][y1],1);
            else edge(id1[x][y],id[x1][y1],1);
        }
    }
    else
    {
        if(a[x1][y1]==2)
        {
            if(x==x1) edge(id[x][y],id2[x1][y1],1);
            else edge(id[x][y],id1[x1][y1],1);
        }
        else edge(id[x][y],id[x1][y1],1);
    }
}
bool is(int x,int y,int x1,int y1)
{
    if(a[x][y]==2)
    {
        if(a[x1][y1]==2)
        {
            if(x==x1) return G[id2[x][y]].count(id2[x1][y1]);
            else return G[id1[x][y]].count(id1[x1][y1]);
        }
        else
        {
            if(x==x1) return G[id2[x][y]].count(id[x1][y1]);
            else return G[id1[x][y]].count(id[x1][y1]);
        }
    }
    else
    {
        if(a[x1][y1]==2)
        {
            if(x==x1) return G[id[x][y]].count(id2[x1][y1]);
            else return G[id[x][y]].count(id1[x1][y1]);
        }
        else return G[id[x][y]].count(id[x1][y1]);
    }
}

int main()
{
    ios_base::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,m,sum[2]={0,0};
    cin>>n>>m;
    for(int i=1;i<=n;i++)
    {
        for(int j=1;j<=m;j++)
        {
            cin>>a[i][j];
            for(int k=0;k<3;k++) for(int l=0;l<3;l++) ans[i][j][k][l]='.';
            if(a[i][j]!=0) ans[i][j][1][1]='O';
            sum[(i+j)%2]+=a[i][j];
        }
    }
    if(sum[0]!=sum[1]) gg();
    edge(1,2,sum[0]);
    int it=2;
    for(int i=1;i<=n;i++)
    {
        for(int j=1;j<=m;j++)
        {
            if(a[i][j]==0) continue;
            id[i][j]=++it;
            if(a[i][j]==2)
            {
                id1[i][j]=++it;
                id2[i][j]=++it;
                if((i+j)%2)
                {
                    edge(id[i][j],id1[i][j],1);
                    edge(id[i][j],id2[i][j],1);
                }
                else
                {
                    edge(id1[i][j],id[i][j],1);
                    edge(id2[i][j],id[i][j],1);
                }
            }
        }
    }
    it+=2;
    t=it;
    edge(it-1,it,sum[0]);
    for(int i=1;i<=n;i++)
    {
        for(int j=1;j<=m;j++)
        {
            if(a[i][j]==0) continue;
            if((i+j)%2) edge(2,id[i][j],a[i][j]);
            else edge(id[i][j],it-1,a[i][j]);
        }
    }
    for(int i=1;i<=n;i++)
    {
        for(int j=1;j<=m;j++)
        {
            if((i+j)%2==0||a[i][j]==0) continue;
            if(a[i-1][j]!=0) connect(i,j,i-1,j);
            if(a[i+1][j]!=0) connect(i,j,i+1,j);
            if(a[i][j-1]!=0) connect(i,j,i,j-1);
            if(a[i][j+1]!=0) connect(i,j,i,j+1);
        }
    }
    if(flow()!=sum[0]) gg();
    //cout<<sum[0]<<endl;
    for(int i=1;i<=n;i++)
    {
        for(int j=1;j<=m;j++)
        {
            if((i+j)%2==0||a[i][j]==0) continue;
            if(a[i-1][j]!=0)
            {
                if(!is(i,j,i-1,j))
                {
                    //cout<<i<<" "<<j<<" "<<i-1<<" "<<j<<endl;
                    ans[i][j][0][1]='X';
                    ans[i-1][j][2][1]='X';
                }
            }
            if(a[i+1][j]!=0)
            {
                if(!is(i,j,i+1,j))
                {
                   // cout<<i<<" "<<j<<" "<<i+1<<" "<<j<<endl;
                    ans[i][j][2][1]='X';
                    ans[i+1][j][0][1]='X';
                }
            }
            if(a[i][j-1]!=0)
            {
                if(!is(i,j,i,j-1))
                {
                   // cout<<i<<" "<<j<<" "<<i<<" "<<j-1<<endl;
                    ans[i][j][1][0]='X';
                    ans[i][j-1][1][2]='X';
                }
            }
            if(a[i][j+1]!=0)
            {
                if(!is(i,j,i,j+1))
                {
                 //   cout<<i<<" "<<j<<" "<<i<<" "<<j+1<<endl;
                    ans[i][j][1][2]='X';
                    ans[i][j+1][1][0]='X';
                }
            }
        }
    }
    for(int i=1;i<=n;i++)
    {
        for(int k=0;k<3;k++)
        {
            for(int j=1;j<=m;j++)
            {
                for(int l=0;l<3;l++)
                {
                    cout<<ans[i][j][k][l];
                }
            }
            cout<<endl;
        }
    }



    return 0;
}
