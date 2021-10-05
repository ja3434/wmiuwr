#include <iostream>
using namespace std;

int t[1000004];

int main()
{
  int i = 0;
  while (true)
  {
    cin >> t[i];
    if (t[i] == -1)
      break;
    i++;
  }
  for (int j = 0; j < i; j += 2)
    cout << t[j] << " ";
  cout << "-1\n";
  for (int j = 1; j < i; j += 2)
    cout << t[j] << " ";
  cout << "-1\n";
}