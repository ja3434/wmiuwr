#include<iostream>
using namespace std;

int main() {
  int a, b;
  cin >> a >> b;
  if (b < a) swap(a,b);
  for (int i = a; i <= b; i++) 
    cout << i << "\n";
}