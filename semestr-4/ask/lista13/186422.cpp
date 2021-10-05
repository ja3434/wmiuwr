#include <bits/stdc++.h>
using namespace std;
const int SIZE=101000;
void imax(int &a, int b){
	a=max(a, b);
}
void imin(int &a, int b){
	a=min(a, b);
}
void lmax(long long &a, long long b){
	a=max(a, b);
}
void lmin(long long &a, long long b){
	a=min(a, b);
}
/*
	WARNING: I'm using strange bracket style!
*/
vector <pair <int, int> > out;
vector <int> v[SIZE], s;
int n, q, x, y;
int main()
	{
	ios::sync_with_stdio(0);
	cin.tie(0);
	cout.tie(0);
	cin>>n>>q;
	while (q--)
		cin>>x>>y, v[min(x, y)].push_back(max(x, y));
	v[1].push_back(n);
	for (int i=1; i<=n; i++)
		{
		sort(v[i].begin(), v[i].end());
		reverse(v[i].begin(), v[i].end());
		while (!s.empty() && s.back()<=i)
			s.pop_back();
		if (!s.empty() && s.back()>i+1)
			if (v[i].size()==0 || s.back()!=v[i][0])
				out.push_back({s.back(), i});
		for (auto j: v[i])
			s.push_back(j);
		}
	cout<<out.size()<<"\n";
	for (auto i: out)
		cout<<i.first<<" "<<i.second<<"\n";
	return 0;
	}
