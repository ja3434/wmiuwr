//Krzysztof Boryczka
#include <bits/stdc++.h>
using namespace std;

typedef long long ll;
typedef long double ld;
typedef pair<int, int> ii;
typedef vector<int> vi;
typedef vector<ii> vii;
const int inf=0x3f3f3f3f;
const ll INF=0x3f3f3f3f3f3f3f3f;

#define FOR(i, b, e) for(int i=b; i<=e; i++)
#define FORD(i, b, e) for(int i=b; i>=e; i--)
#define SIZE(x) ((int)x.size())
#define pb push_back
#define st first
#define nd second
#define sp ' '
#define ent '\n'

ifstream out, wzor, in;

int main(int argc, char *argv[]){
	assert(argc>=4);

	out.open(argv[1]);
	wzor.open(argv[2]);
	in.open(argv[3]);

	vector<string> ans, user;
	string pom;
	while(wzor>>pom) ans.pb(pom);
	while(out>>pom) user.pb(pom);
	FOR(i, 1, 5) in>>pom;

	if(ans!=user)
	{
		if(pom != "0" && pom != "1" && pom != "3" && pom != "5"){
			cout << "Zla odpowiedz\n";
			exit(1);
		}
		int d=0, g=0, m=0, s=0;
		FOR(i, 0, SIZE(ans)-1){
			if(ans[i][0]=='d') d=stoi(ans[i-1]);
			if(ans[i][0]=='g') g=stoi(ans[i-1]);
			if(ans[i][0]=='m') m=stoi(ans[i-1]);
			if(ans[i][0]=='s') s=stoi(ans[i-1]);
		}
		if(SIZE(user)!=4 || stoi(user[0])!=d || stoi(user[1])!=g || stoi(user[2])!=m || stoi(user[3])!=s){
			cout << "Zla odpowiedz\n";
			exit(1);
		}
	}

	cout << "OK\n";
	exit(0);
}
