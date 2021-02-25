#include <iostream>

using namespace std;
int tab[100];
int main()
{
    int x,n,j;
    for(int i=0;i<=1000;i++)
    {
     cin>>x;
     if(x==-1)
     {
         break;
     }
     tab[x]++;
    }
    for(int i=0;i<=100;i++)
  {
   j=0;
   while(j<tab[i]){
    cout<<i<<" ";
    j++;
   }

  }
    return 0;
}