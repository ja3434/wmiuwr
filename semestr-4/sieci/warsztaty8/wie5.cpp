#include <bits/stdc++.h>

using namespace std;
typedef long long ll;

mt19937 rng(rand());
const int MAXDEG = 10000;
long long poly[MAXDEG+1];
int deg;

int gcd(int a, int b){
	return !b ? a : gcd(b, a%b);
}

struct rat{
	int sign;
	int num, den;
	
	void cancel(){
		int d = gcd(num, den);
		this->num /= d;
		this->den /= d;
	}
	
	rat(int a, int b){
		this->sign = 1;
		if(a == 0){
			this->sign = 0;
			this->num = 0;
			this->den = 1;
			return;
		} 
		if(b < 0){
			this->sign = -1;
		}
		this->den = abs(b);
		if(a < 0){
			this->sign = -(this->sign);
		}
		this->num = abs(a);
		cancel();
	}

	bool operator<(const rat &x) const {
		if(this->sign != x.sign) return this->sign < x.sign;
		
		bool abs_less;
		long long int left = (long long)(this->num) * (long long)(x.den);
		long long int right = (long long)(x.num) * (long long)(this->den);
		abs_less = left < right;
		
		if(left == right) return false;
		if(this->sign == -1) return !abs_less;
		if(this->sign == 0) return false;
		if(this->sign == 1) return abs_less;
	}
	
	bool operator==(const rat &x) const {
		return this->sign == x.sign && this->num == x.num && this->den == x.den;
	}
	
	friend ostream& operator<<(ostream &stream, const rat &x){
		if(x.sign == -1) stream << '-';
		stream << x.num << "/" << x.den;
		return stream;
	}
};

ll W(rat x, int mod){
	ll out = 0;
	ll den_pow = 1;
	ll num = x.num;
	ll den = x.den;
	if(x.sign == -1) num = mod-num;
	for(int i = deg; i >= 0; i--){
		out += (poly[i]*den_pow)%mod;
		if(i) out *= num;
		out %= mod;
		den_pow = (den_pow * den)%mod;
	}
	//cerr << x << " " << mod << " " << out << endl;
	return out;
}

bool check(rat x){
	for(int i = 0; i < 20; i++){
		int p = uniform_int_distribution<int>(2, 1000000000)(rng);
		if(W(x, p)){
			//cerr << x << " " << p << endl;
			return false;
		}
	}
	return true;
}

vector< int > nums;
vector< int > dens;
vector< rat > candidates_mult;
vector< rat > candidates;
void cands(){
	for(int i = 1; i*i <= abs(poly[0]); i++){
		if(abs(poly[0]) % i) continue;
		nums.push_back(i);
		nums.push_back(-i);
		nums.push_back(poly[0]/i);
		nums.push_back(-poly[0]/i);
	}
	
	for(int i = 1; i*i <= abs(poly[deg]); i++){
		if(abs(poly[deg]) % i) continue;
		dens.push_back(i);
		dens.push_back(poly[deg]/i);
	}
	
	//cerr << nums.size() << " * " << dens.size() << " = " << (nums.size())*(dens.size()) << endl;
	
	for(int p : nums){
		for(int q : dens){
			candidates_mult.push_back({p, q});
		}
	}
	sort(candidates_mult.begin(), candidates_mult.end());
	candidates.push_back(candidates_mult[0]);
	for(int i = 1; i < candidates_mult.size(); i++){
		if(!(candidates_mult[i-1] == candidates_mult[i])){
			candidates.push_back(candidates_mult[i]);
		}
	}
	
	//for(rat r : candidates) cerr << r << endl;
}

vector< rat > s;
void solve(){
	if(!poly[0]){
		s.push_back({0, 1});
		int k = 0;
		while(poly[k] == 0) k++;
		for(int i = 0; i <= deg-k; i++) poly[i] = poly[i+k];
		deg -= k;
	}
	
	cands();
	for(rat c : candidates) if(check(c)) s.push_back(c);
	sort(s.begin(), s.end());
	cout << s.size() << "\n";
	for(rat i : s) cout << i << " ";  
}

int main(){	
	ios_base::sync_with_stdio(0);
	cin.tie(0);
	cout.tie(0);
	
	cin >> deg;
	for(int i = 0; i <= deg; i++) cin >> poly[deg-i];
	solve();
}
