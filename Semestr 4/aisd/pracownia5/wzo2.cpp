#include <bits/stdc++.h>
using namespace std;

/* 
[0 -1]
[1  0]
*/

struct pnt {
  int x, y;
  pnt (int _x=0, int _y=0) : x(_x), y(_y) {}
  void transpose(int a11, int a12, int a21, int a22) {
    int temp = x*a11 + y*a12;
    y = x*a21 + y*a22;
    x = temp;
  }
  bool operator<(const pnt &p) const {
    if (p.x == x) return y < p.y;
    return x < p.x;
  }
  bool operator==(const pnt &p) const {
    return (x == p.x && y == p.y);
  }
};

struct seg {
  pnt st, nd;
  seg(pnt p1=pnt(), pnt p2=pnt()) : st(p1), nd(p2) {}
  void transpose(int a11, int a12, int a21, int a22) {
    st.transpose(a11, a12, a21, a22);
    nd.transpose(a11, a12, a21, a22);
  }
};

#define HOR_T 0
#define VER_T 1
#define CL_T 2
#define CR_T 3
#define BEG 0
#define END 1

struct event {
  int x;
  int t;
  int i1, i2;

  event(int _x, int _t, int _i1, int _i2) : x(_x), t(_t), i1(_i1), i2(_i2) {}

  bool operator < (const event &e) const {
    if (x == e.x) {
      if (t == e.t) return make_pair(i1, i2) < make_pair(e.i1, e.i2);
      if (t == HOR_T) return (e.i2 == END);
      if (e.t == HOR_T) return (i2 == BEG);
      return t < e.t;
    }
    return x < e.x;
  }
};

inline void swap(pnt &p1, pnt &p2) {
  swap(p1.x, p2.x);
  swap(p1.y, p2.y);
}

vector<seg> segments;
vector<pnt> result; 
vector<pnt> temp_res;
vector<event> events;
map<int, int> hor;
map<int, int> cl;
map<int, int> cr;

void read() {
  int n;
  scanf("%d", &n);
  segments.resize(n);
  for (int i = 0; i < n; i++) {
    cin >> segments[i].st.x >> segments[i].st.y >> segments[i].nd.x >> segments[i].nd.y;
  }
} 

void rotate(int a11, int a12, int a21, int a22) {
  for (auto s: segments) {
    s.transpose(a11, a12, a21, a22);
  }
}

void solve_prob() {
  temp_res.clear();
  events.clear();
  hor.clear(); cl.clear(); cr.clear();

  for (auto s: segments) {
    if (s.st.x > s.nd.x) swap(s.st, s.nd);
    if (s.st.x == s.nd.x) {
      if (s.st.y > s.nd.y) swap(s.st, s.nd);
      events.push_back(event(s.st.x, VER_T, s.st.y, s.nd.y));
    }
    else if (s.st.y == s.nd.y) {
      events.push_back(event(s.st.x, HOR_T, s.st.y, BEG));
      events.push_back(event(s.nd.x, HOR_T, s.st.y, END));
    }
    else if (s.st.y - s.nd.y < 0) {
      events.push_back(event(s.st.x, CR_T, s.st.y, BEG));  
      events.push_back(event(s.nd.x, CR_T, s.nd.y, END));  
    }
    else {
      events.push_back(event(s.st.x, CL_T, s.st.y, BEG));  
      events.push_back(event(s.nd.x, CL_T, s.nd.y, END));  
    }
  }

  sort(events.begin(), events.end());
  for (auto e: events) {
    if (e.t == VER_T) {
      auto it = hor.lower_bound(e.i1);
      while (it != hor.end() && it->first <= e.i2) {
        temp_res.push_back({e.x, it->first});
        it++;
      }
      it = cr.lower_bound(e.i1 - e.x);
      while (it != cr.end() && it->first <= e.i2 - e.x) {
        temp_res.push_back({e.x, it->first + e.x});
        it++;
      }
      it = cl.lower_bound(e.i1 + e.x);
      while (it != cl.end() && it->first <= e.i2 + e.x) {
        temp_res.push_back({e.x, it->first - e.x});
        it++;
      }
    } 
    if (e.t == CR_T) {
      if (e.i2 == BEG) cr[e.i1 - e.x]++;
      else if (--cr[e.i1 - e.x] <= 0) cr.erase(e.i1 - e.x);
    }
    if (e.t == CL_T) {
      if (e.i2 == BEG) cl[e.i1 + e.x]++;
      else if (--cl[e.i1 + e.x] <= 0) cl.erase(e.i1);
    }
    if (e.t == HOR_T) {
      if (e.i2 == BEG) hor[e.i1]++;
      else if (--hor[e.i1] <= 0) hor.erase(e.i1);
    }
  }
}

void add_to_res(int a11, int a12, int a21, int a22) {
  for (auto p: temp_res) {
    p.transpose(a11, a12, a21, a22);
    result.push_back(p);
  }
}

void solve() {
  solve_prob();
  for (auto &p: temp_res) {
    p.x *= 2; p.y *= 2;
  }
  add_to_res(1, 0, 0, 1);
  for (auto &p: temp_res) {
    p.x /= 2; p.y /= 2;
  }
  rotate(1, -1, 1, 1);
  solve_prob();
  add_to_res(1, 1, -1, 1);
  rotate(1, 1, -1, 1);
  for (auto &p: temp_res) {
    p.x /= 2; p.y /= 2;
  } 

  

  sort(result.begin(), result.end());
  result.erase(unique(result.begin(), result.end()), result.end());
  for (auto p : result) {
    cout << p.x/2 << "." << (p.x % 2 == 1 ? "5" : "0") << " ";
    cout << p.y/2 << "." << (p.y % 2 == 1 ? "5" : "0") << "\n";
  }
}

int main() {
  read();
  solve();
}