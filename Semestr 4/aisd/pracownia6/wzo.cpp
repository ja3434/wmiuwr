#include <bits/stdc++.h>
using namespace std;

const int N = 1e6 + 10;
bool vis[N];
int n, m, ranga[N], par[N];
pair<int, pair<int, int>> G[N];

int Find(int v) {
  if (par[v] == v) return v;
  return par[v] = Find(par[v]);
}

void Union(int v, int u) {
  if (ranga[v] > ranga[u]) {
    par[u] = v;
  }
  else {
    if (ranga[v] == ranga[u]) ranga[u]++;
    par[v] = u;
  }
}

bool traj(int maks) {

}

int main() {
  scanf("%d%d", &n, &m);  
  for (int i = 0; i < m; i++) {
    int a, b, w;
    scanf("%d%d%d", &a, &b, &w);
    G[i] = {-w, {a,b}};
  }
  sort(G, G+m);
  for (int i = 1; i <= n; i++) {
    par[i] = i;
    ranga[i] = 0;
  }
  int mini = 1e9;
  for (int i = 0; i < m; i++) {
    int a = G[i].second.first;
    int b = G[i].second.second;
    a = Find(a); b = Find(b);
    if (a != b) {
      Union(a, b);
      mini = min(mini, -G[i].first);
    }
  }
  printf("%d\n", mini);
}