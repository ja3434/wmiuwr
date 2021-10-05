// solution written by Michal 'misof' Forisek
#include <vector>
#include <set>
#include <queue>
#include <iostream>
using namespace std;

#define FOREACH(it,c) for(__typeof((c).begin()) it=(c).begin();it!=(c).end();++it)

class MaximumMatching {
        int left_size, right_size;
        vector< vector<int> > right_to_left;

        public:
        MaximumMatching() { left_size=right_size=0; right_to_left.clear(); }
        void add_edge(int left, int right);
        vector< pair<int,int> > maximum_matching();
};

void MaximumMatching::add_edge(int left, int right) {
        if (left==-1 || right==-1) return;
        if (left_size <= left) left_size = left+1;
        if (right_size <= right) { right_size = right+1; right_to_left.resize(right_size); }
        right_to_left[right].push_back(left);
}

vector< pair<int,int> >
MaximumMatching::maximum_matching() {
        int L = left_size, R = right_size;
        vector<int> match(L,-1);
        for (int r=0; r<R; r++) {
                bool found = false;
                vector<int> from(L,-1);
                queue<int> Q;
                FOREACH(it,right_to_left[r]) { Q.push(*it); from[*it]=*it; }
                while (!Q.empty() && !found) {
                        int l = Q.front(); Q.pop();
                        if (match[l]==-1) {
                                found = true;
                                while (from[l]!=l) { match[l] = match[from[l]]; l = from[l]; }
                                match[l]=r;
                        } else {
                                FOREACH(it,right_to_left[ match[l] ]) if (from[*it]==-1) { Q.push(*it); from[*it]=l; }
                        }
                }
        }
        vector< pair<int,int> > result;
        for (int i=0; i<L; i++) if (match[i] != -1) result.push_back(make_pair(i,match[i]));
        return result;
}

int R, C; // the dimensions of the island
vector< vector<int> > A; // the map of the island

int ENCODE(int r, int c, int n) { return (C*r+c)*5+n; }
int LEFT(int r, int c) { if (A[r][c]==0) return -1; else if (A[r][c]<=2) return ENCODE(r,c,0); else return ENCODE(r,c,1); }
int RIGHT(int r, int c) { if (A[r][c]==0) return -1; else if (A[r][c]<=2) return ENCODE(r,c,0); else return ENCODE(r,c,3); }
int TOP(int r, int c) { if (A[r][c]==0) return -1; else if (A[r][c]==2) return ENCODE(r,c,1); else return ENCODE(r,c,0); }
int BOTTOM(int r, int c) { if (A[r][c]==0) return -1; else if (A[r][c]<=2) return ENCODE(r,c,A[r][c]-1); else return ENCODE(r,c,2); }
#define VERTEX(r,c,dir) ( ((r<0) || (c<0) || (r>=R) || (c>=C)) ? -1 : dir(r,c) )

int main() {
        // read the input
        cin >> R >> C;
        A.resize(R, vector<int>(C) );
        for (int r=0; r<R; ++r) for (int c=0; c<C; ++c) cin >> A[r][c];

        // create the bipartite graph
        MaximumMatching MM;
        for (int r=0; r<R; ++r) for (int c=0; c<C; ++c) {
               int left, right;
               left=VERTEX(r,c,LEFT);   right=VERTEX(r,c-1,RIGHT);  if ((r+c)%2) swap(left,right); MM.add_edge(left,right);
               left=VERTEX(r,c,TOP);    right=VERTEX(r-1,c,BOTTOM); if ((r+c)%2) swap(left,right); MM.add_edge(left,right);
               if (A[r][c]==3) for (int d=0; d<4; ++d) {
                      left=ENCODE(r,c,d); right=ENCODE(r,c,4); if ((r+c)%2) swap(left,right); MM.add_edge(left,right);
               }
        }

        // find a maximum matching and check its size
        int expected_size = 0;
        for (int r=0; r<R; ++r) for (int c=0; c<C; ++c) expected_size += A[r][c] + (A[r][c]==3 ? 2 : 0);
        vector< pair<int,int> > matching = MM.maximum_matching();
        if (2*matching.size() != expected_size) { cout << "NIE" << endl; return 0; }

        // from the edges of the matching, reconstruct the map
        set< pair<int,int> > edges;
        FOREACH(it,matching) { edges.insert(make_pair(it->first,it->second)); edges.insert(make_pair(it->second,it->first)); }
        vector<string> output(3*R, string(3*C,'.'));
        for (int r=0; r<R; ++r) for (int c=0; c<C; ++c) if (A[r][c]) {
                output[3*r+1][3*c+1]='O';
                if (edges.count(make_pair(VERTEX(r,c,LEFT),  VERTEX(r,c-1,RIGHT))))  output[3*r+1][3*c]='X';
                if (edges.count(make_pair(VERTEX(r,c,RIGHT), VERTEX(r,c+1,LEFT))))   output[3*r+1][3*c+2]='X';
                if (edges.count(make_pair(VERTEX(r,c,TOP),   VERTEX(r-1,c,BOTTOM)))) output[3*r][3*c+1]='X';
                if (edges.count(make_pair(VERTEX(r,c,BOTTOM),VERTEX(r+1,c,TOP))))    output[3*r+2][3*c+1]='X';
        }
        for (int r=0; r<3*R; ++r) cout << output[r] << endl;
}
