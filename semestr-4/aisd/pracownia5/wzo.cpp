#include <bits/stdc++.h>
using namespace std;

#define VER_T 1
#define HOR_T 0

#define BEG 0
#define END 1

struct event {
  int x, y, z;
  bool t;
  event(int _x=0, bool _t=false, int _y=0, int _z=0) : x(_x), y(_y), z(_z), t(_t) {}

  bool operator < (const event &e) const {
    if (x == e.x) {
      if (t == e.t) return make_pair(y, z) < make_pair(e.y, e.z);
      if (t == HOR_T) return z == BEG;
      if (e.t == HOR_T) return e.z == END;
      return t < e.t;
      // if (t == HOR_T && z == BEG) return true;
      // else if (t == HOR_T) return false;
      // else if (e.t == HOR_T && e.z == BEG) return false;
      // else if (e.t == HOR_T) return true;
      // return (make_pair(y,z) < make_pair(e.y, e.z));
    }
    return x < e.x;
    // return make_pair(x, make_pair(t, make_pair(y, z))) < make_pair(e.x, make_pair(e.t, make_pair(e.y, e.z)));
  }

};

struct pnt {
  int x, y;

  pnt(int _x=0, int _y=0) : x(_x), y(_y) {}

  void transpoze(int a11, int a12, int a21, int a22) {
    int temp = x*a11 + y*a12;
    y = x*a21 + y*a22;
    x = temp;
  }
  bool operator == (const pnt &p) {
    return (x==p.x && y == p.y);
  }

};

struct seg {
  pnt st, nd;

  seg(pnt p1=pnt(), pnt p2=pnt()) : st(p1), nd(p2) {}

  void transpoze(int a11, int a12, int a21, int a22) {
    st.transpoze(a11, a12, a21, a22);
    nd.transpoze(a11, a12, a21, a22);
  }
};

inline int sig(int x) {
  if (x < 0)  return -1;
  if (x == 0) return 0;
  if (x > 0)  return 1;
}

void swap(pnt &x, pnt &y) {
  swap(x.x, y.x);
  swap(x.y, y.y);
}

vector<event> events;
map<int, int> points;

void get_cross_pnts(vector<pnt> &result, vector<seg> &hor, vector<seg> &ver) {
  events.resize(0);
  points.clear();
  // cout << "h:\n";
  for (auto &s: hor) {
    if (s.st.x > s.nd.x) swap(s.st, s.nd);
    // cout << s.st.x << " " << s.st.y << ", " << s.nd.x << " " <<  s.nd.y << "\n";
    events.push_back(event(s.st.x, HOR_T, s.st.y, BEG));
    events.push_back(event(s.nd.x, HOR_T, s.st.y, END));
  }
  // cout << "v:\n";
  for (auto &s: ver) {
    if (s.st.y > s.nd.y) swap(s.st, s.nd);
    // cout << s.st.x << " " << s.st.y << ", " << s.nd.x << " " <<  s.nd.y << "\n";

    events.push_back(event(s.st.x, VER_T, s.st.y, s.nd.y));
  }

  sort(events.begin(), events.end());
  for (auto e: events) {
    // cout << e.x << " " << (e.t == HOR_T ? "hor " : "ver ") << e.y << " " << (e.t == HOR_T ? (e.z == BEG ? "beg" : "end") : to_string(e.z)) << "\n";
    if (e.t == HOR_T) {
      if (e.z == BEG) points[e.y]++;
      else {
        if (--points[e.y] == 0) points.erase(e.y);
      }
    }
    else {
      auto it = points.lower_bound(e.y);
      while (it != points.end() && it->first <= e.z) {
        result.push_back(pnt(e.x, it->first));
        it++;
      }
    }
  }
  // cout << "done\n";
}

vector<pnt> temp;
vector<seg> hor, ver, cross_left, cross_right; 

void read() {
  int n;
  // cin >> n;
  scanf("%d", &n);
  for (int i = 0; i < n; i++) {
    int x1, y1, x2, y2;
    // cin >> x1 >> y1 >> x2 >> y2;
    scanf("%d%d%d%d", &x1, &y1, &x2, &y2);
    seg s = seg(pnt(x1, y1), pnt(x2, y2));
    if (y1 == y2)                      
      hor.push_back(s);
    else if (x1 == x2)                      
      ver.push_back(s);
    else if (sig(x1 - x2) == sig(y1 - y2))  
      cross_right.push_back(s);
    else
      cross_left.push_back(s);      
  }
}

void hor_ver(vector<pnt> &result) {
  // cout << "hor_ver\n";

  temp.clear();
  get_cross_pnts(temp, hor, ver);
  for (auto p: temp) result.push_back(p);
}

void hor_c_r(vector<pnt> &result) {
  // cout << "hor_cr\n";
  temp.clear();
  for (auto &p: hor)          p.transpoze(1, -1, 0, 1);
  for (auto &p: cross_right)  p.transpoze(1, -1, 0, 1); 
  get_cross_pnts(temp, hor, cross_right);
  for (auto &p: hor)          p.transpoze(1, 1, 0, 1);
  for (auto &p: cross_right)  p.transpoze(1, 1, 0, 1);

  for (auto &p: temp) {
    p.transpoze(1, 1, 0, 1);
    result.push_back(p);
  }
}

void hor_c_l(vector<pnt> &result) {
  // cout << "hor_cl\n";
  temp.clear();
  for (auto &p: hor)        p.transpoze(1, 1, 0, 1);
  for (auto &p: cross_left) p.transpoze(1, 1, 0, 1);

  get_cross_pnts(temp, hor, cross_left);
 
  for (auto &p: hor)        p.transpoze(1, -1, 0, 1);
  for (auto &p: cross_left) p.transpoze(1, -1, 0, 1);
 
  for (auto &p: temp) {
    p.transpoze(1, -1, 0, 1);
    result.push_back(p);
  }
}

void ver_c_r(vector<pnt> &result) {
  // cout << "ver_cr\n";

  temp.clear();
  for (auto &p: ver) {
    p.transpoze(1, 0, -1, 1);
  }
  for (auto &p: cross_right) {
    p.transpoze(1, 0, -1, 1);
  }
 
  get_cross_pnts(temp, cross_right, ver);
 
  for (auto &p: ver) {
    p.transpoze(1, 0, 1, 1);
  }
  for (auto &p: cross_right) {
    p.transpoze(1, 0, 1, 1);
  }
 
  for (auto &p: temp) {
    p.transpoze(1, 0, 1, 1);
    result.push_back(p);
  }
}

void ver_c_l(vector<pnt> &result) {
  // cout << "ver_cl\n";

  temp.clear();
  for (auto &p: ver) {
    p.transpoze(-1, 0, 1, 1);
  }
  for (auto &p: cross_left) {
    p.transpoze(-1, 0, 1, 1);
  }
 
  get_cross_pnts(temp, cross_left, ver);
  for (auto &p: ver) {
    p.transpoze(-1, 0, 1, 1);
  }
  for (auto &p: cross_left) {
    p.transpoze(-1, 0, 1, 1);
  }
 
  for (auto &p: temp) {
    p.transpoze(-1, 0, 1, 1);
    result.push_back(p);
  }
}

void c_l_c_r(vector<pnt> &result) {
  temp.clear();
  // cout << "cl_cr\n";
  for (auto &p: cross_right) {
    // cout << p.st.x << " " << p.st.y << ", " << p.nd.x << " " <<  p.nd.y << "\n";
    p.transpoze(1, 1, -1, 1);
  }
  // cout << "---\n";
  for (auto &p: cross_left) {
    // cout << p.st.x << " " << p.st.y << ", " << p.nd.x << " " <<  p.nd.y << "\n";
    p.transpoze(1, 1, -1, 1);
  }
 
  get_cross_pnts(temp, cross_right, cross_left);
 
  for (auto &p: ver) {
    p.transpoze(1, -1, 1, 1);
  }
  for (auto &p: cross_left) {
    p.transpoze(1, -1, 1, 1);
  }
 
  for (auto &p: temp) {
    p.transpoze(1, -1, 1, 1);
    result.push_back(p);
  }
}

void solve() {
  // cout << hor.size() << " " << ver.size() << " " << cross_left.size() << " " << cross_right.size() << "\n";
  vector<pnt> result;
  hor_ver(result);
  hor_c_r(result);
  hor_c_l(result);
  ver_c_r(result);
  ver_c_l(result);
  for (auto &p: result) {
    p.x *= 2;
    p.y *= 2;
  }
  c_l_c_r(result);

  sort(result.begin(), result.end(), [&](const pnt &p1, const pnt &p2) {
    if (p1.x == p2.x) return p1.y < p2.y;
    return p1.x < p2.x;
  });
  result.erase(unique(result.begin(), result.end()), result.end());

  printf("%d\n", result.size());
  for (auto p : result) {
    printf("%d.%s ", p.x/2, (p.x % 2 == 1 ? "5" : "0"));
    printf("%d.%s\n", p.y/2, (p.y % 2 == 1 ? "5" : "0"));
    // cout << p.x/2 << "." << (p.x % 2 == 1 ? "5" : "0") << " ";
    // cout << p.y/2 << "." << (p.y % 2 == 1 ? "5" : "0") << "\n";
  }
}

int main() { 
  // ios_base::sync_with_stdio(false);
  // cin.tie();
  read();
  solve();
}
