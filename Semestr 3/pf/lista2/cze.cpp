#include <iostream>
using namespace std;

int tab[1000010];

int main()
{
  int wsk = 0;

  while (true)
  {
    cin >> tab[wsk];
    if (tab[wsk] == -1)
      break;
    wsk++;
  }

  for (int i = 0; i < wsk; i += 2) // i += 2 <=> i = i + 2
  {
    cout << tab[i] << " ";
  }
  cout << "-1\n";

  for (int i = 1; i < wsk; i += 2)
  {
    cout << tab[i] << " ";
  }
  cout << "-1\n";
}