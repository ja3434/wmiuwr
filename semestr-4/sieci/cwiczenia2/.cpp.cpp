#include<bits/stdc++.h>
#define fi first
#define se second
using namespace std;
const int N=1e5;
vector<int> e[N+10];
int g[N+10];
int dfs(int x,int k)
{
	int ans=0;
	g[x]=0;
	for(auto v:e[x])
	{
		ans+=dfs(v,k);
		if(g[v]+1==k)
		{
			if(x!=1)
				ans++;
			g[v]=-1;
		}
		g[x]=max(g[x],g[v]+1);
	}
	return ans;
}
int main()
{
	ios_base::sync_with_stdio(false);
	cin.tie(NULL);
	cout.tie(NULL);
	int n,k;
	cin>>n>>k;
	for(int i=1;i<n;i++)
	{
		int a,b;
		cin>>a>>b;
		e[b].push_back(a);
	}
	cout<<dfs(1,k)<<"\n";
	return 0;
}

