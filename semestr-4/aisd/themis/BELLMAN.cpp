#include <bits/stdc++.h>
using namespace std;

const int N = 503;
int dist[N];
vector<pair<int, pair<int, int>>> edges;
int main()
{
  ios_base::sync_with_stdio(false);
  cin.tie();
  int n, m, s;
  cin >> n >> m >> s;
  for (int i = 0; i <= n; i++)
  {
    dist[i] = 2e9;
  }
  dist[s] = 0;
  for (int i = 0; i < m; i++)
  {
    int u, v, w;
    cin >> u >> v >> w;
    edges.push_back({w, {u, v}});
    // edges.push_back({w, {v, u}});
  }

  for (int i = 0; i < n + 1; i++)
  {
    for (auto e : edges)
    {
      int w = e.first;
      int u = e.second.first;
      int v = e.second.second;
      if (dist[v] > dist[u] + w)
      {
        dist[v] = dist[u] + w;
      }
    }
  }
  for (auto e : edges)
  {
    int w = e.first;
    int u = e.second.first;
    int v = e.second.second;
    if (dist[v] > dist[u] + w)
    {
      cout << "NIE\n";
      return 0;
    }
  }
  for (int i = 0; i < n; i++)
  {
    if (i != s && dist[i] < 1e9)
      cout << i << " " << dist[i] << "\n";
  }
}