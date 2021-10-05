#include <bits/stdc++.h>

using namespace std;

const int MAXN = 70;
int tab[MAXN][MAXN];
char out[3*MAXN][3*MAXN];
int N, M;

int id(int x, int y, int strona){ //0 - prawo, 1 - g�ra, 2 - lewo, 3 - d��
	if(strona == 0){
		if(x+1 >= N) return -1;
		if(tab[x+1][y] == 0) return -1;
		if(tab[x+1][y] == 1) return 5*(MAXN*(x+1)+y);
		if(tab[x+1][y] == 2) return 5*(MAXN*(x+1)+y);
		if(tab[x+1][y] == 3) return 5*(MAXN*(x+1)+y)+2;
		if(tab[x+1][y] == 4) return 5*(MAXN*(x+1)+y)+2;
	}
	if(strona == 1){
		if(y+1 >= M) return -1;
		if(tab[x][y+1] == 0) return -1;
		if(tab[x][y+1] == 1) return 5*(MAXN*x+y+1);
		if(tab[x][y+1] == 2) return 5*(MAXN*x+y+1)+1;
		if(tab[x][y+1] == 3) return 5*(MAXN*x+y+1)+3;
		if(tab[x][y+1] == 4) return 5*(MAXN*x+y+1)+3;
	}
	if(strona == 2){
		if(x-1 < 0) return -1;
		if(tab[x-1][y] == 0) return -1;
		if(tab[x-1][y] == 1) return 5*(MAXN*(x-1)+y);
		if(tab[x-1][y] == 2) return 5*(MAXN*(x-1)+y);
		if(tab[x-1][y] == 3) return 5*(MAXN*(x-1)+y);
		if(tab[x-1][y] == 4) return 5*(MAXN*(x-1)+y);
	}
	if(strona == 3){
		if(y-1 < 0) return -1;
		if(tab[x][y-1] == 0) return -1;
		if(tab[x][y-1] == 1) return 5*(MAXN*x+y-1);
		if(tab[x][y-1] == 2) return 5*(MAXN*x+y-1)+1;
		if(tab[x][y-1] == 3) return 5*(MAXN*x+y-1)+1;
		if(tab[x][y-1] == 4) return 5*(MAXN*x+y-1)+1;
	}
}

set<int> real_v;
vector<int> edges[5*MAXN*MAXN+5];
int match[5*MAXN*MAXN+5];
bool mark[5*MAXN*MAXN+5];
bool dfs(int v){
	if(real_v.count(v) == 0) return false;
	if(mark[v]) return false;
	mark[v] = true;
	for(auto &u : edges[v])
		if(match[u] == -1 || dfs(match[u]))
			return match[v] = u, match[u] = v, true;
	return false;
}

int main(){
	cin >> N >> M;
	for(int i = 0; i < N; i++){
		for(int j = 0; j < M; j++){
			cin >> tab[i][j];
		}
	}

	for(int i = 0; i < N; i++){
		for(int j = 0; j < M; j++){
			if(tab[i][j] == 1){
				for(int k = 0; k < 4; k++){
					if(id(i, j, k) != -1) edges[5*(MAXN*i+j)].push_back(id(i, j, k));
				}
				real_v.insert(5*(MAXN*i+j));
			}
			if(tab[i][j] == 2){
				for(int k = 0; k < 4; k++){
					if(id(i, j, k) != -1) edges[5*(MAXN*i+j)+(k%2)].push_back(id(i, j, k));
				}
				real_v.insert(5*(MAXN*i+j)), real_v.insert(5*(MAXN*i+j)+1);
			}
			if(tab[i][j] == 3){
				for(int k = 0; k < 4; k++){
					if(id(i, j, k) != -1) edges[5*(MAXN*i+j)+k].push_back(id(i, j, k));
					edges[5*(MAXN*i+j)+k].push_back(5*(MAXN*i+j)+4);
					edges[5*(MAXN*i+j)+4].push_back(5*(MAXN*i+j)+k);
				}
				real_v.insert(5*(MAXN*i+j)), real_v.insert(5*(MAXN*i+j)+1), real_v.insert(5*(MAXN*i+j)+2), real_v.insert(5*(MAXN*i+j)+3), real_v.insert(5*(MAXN*i+j)+4);
			}
			if(tab[i][j] == 4){
				for(int k = 0; k < 4; k++){
					if(id(i, j, k) != -1) edges[5*(MAXN*i+j)+k].push_back(id(i, j, k));
				}
				real_v.insert(5*(MAXN*i+j)), real_v.insert(5*(MAXN*i+j)+1), real_v.insert(5*(MAXN*i+j)+2), real_v.insert(5*(MAXN*i+j)+3);
			}
		}
	}

	/*for(int i = 0; i < 5*MAXN*MAXN+5; i++){
		if(!edges[i].empty()){
			cerr << "Edges of " << i << ": ";
			for(int v : edges[i]) cerr << v << " ";
			cerr << "\n";
		}
	}*/

	for(int i = 0; i < 5*MAXN*MAXN+5; i++) match[i] = -1;
	for(int i = 0; i < 5*MAXN*MAXN+5; i++)
		if(match[i] == -1){
			memset(mark, false, sizeof mark);
			dfs(i);
		}

	for(int i : real_v) if(match[i] == -1){
		cout << "NIE";
		return 0;
	}

	for(int i = 0; i < N; i++){
		for(int j = 0; j < M; j++){
			if(tab[i][j] == 1){
				int str;
				for(int k = 0; k < 4; k++) if(match[5*(MAXN*i+j)] == id(i, j, k)){
					str = k;
				}
				out[3*i+1][3*j+1] = 'O';
				if(str == 0) out[3*i+2][3*j+1] = 'X';
				if(str == 1) out[3*i+1][3*j+2] = 'X';
				if(str == 2) out[3*i][3*j+1] = 'X';
				if(str == 3) out[3*i+1][3*j] = 'X';
			}
			if(tab[i][j] == 2){
				int strh, strv;
				for(int k = 0; k < 4; k++) if(match[5*(MAXN*i+j)] == id(i, j, k)){
					strh = k;
				}
				for(int k = 0; k < 4; k++) if(match[5*(MAXN*i+j)+1] == id(i, j, k)){
					strv = k;
				}
				out[3*i+1][3*j+1] = 'O';
				if(strh == 0) out[3*i+2][3*j+1] = 'X';
				if(strv == 1) out[3*i+1][3*j+2] = 'X';
				if(strh == 2) out[3*i][3*j+1] = 'X';
				if(strv == 3) out[3*i+1][3*j] = 'X';
			}
			if(tab[i][j] == 3){
				int str;
				for(int k = 0; k < 4; k++) if(match[5*(MAXN*i+j)+4] == 5*(MAXN*i+j)+k){
					str = k;
				}
				out[3*i+1][3*j+1] = 'O';
				out[3*i+2][3*j+1] = 'X';
				out[3*i+1][3*j+2] = 'X';
				out[3*i][3*j+1] = 'X';
				out[3*i+1][3*j] = 'X';
				if(str == 0) out[3*i+2][3*j+1] = '.';
				if(str == 1) out[3*i+1][3*j+2] = '.';
				if(str == 2) out[3*i][3*j+1] = '.';
				if(str == 3) out[3*i+1][3*j] = '.';
			}
			if(tab[i][j] == 4){
				out[3*i+1][3*j+1] = 'O';
				out[3*i+2][3*j+1] = 'X';
				out[3*i+1][3*j+2] = 'X';
				out[3*i][3*j+1] = 'X';
				out[3*i+1][3*j] = 'X';
			}
		}
	}

	for(int i = 0; i < 3*N; i++){
		for(int j = 0; j < 3*M; j++){
			if(!out[i][j]) cout << ".";
			else cout << out[i][j];
		}
		cout << "\n";
	}
}
