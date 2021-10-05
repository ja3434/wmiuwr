#include <bits/stdc++.h>
using namespace std;

void dziesiatki ( int x);
void sety ( int x);

string od1do9[]= { "zero", "jeden", "dwa", "trzy", "cztery", "piec", "szesc", "siedem", "osiem", "dziewiec"};
string od10do19[]= { "dziesiec", "jedynascie", "dwanascie", "trzynascie", "czternascie", "pietnascie", "szesnascie", "siedemnaœcie", "osiemnascie", "dziewietnascie"};
string od20do90[]= {"", "dwadziescia", "trzydziesci", "czterdziesci", "piecdziesciat", "szescdziesciat", "siedemdziesiat", "osiemdziesiat", "dziewiecdziesiat"};
string od200do900[]= { "", "dwiescie", "trzysta", "czterysta", "piecset", "szescset", "siedemset", "osiemset", "dziewiecset"};

void miliony ( int x) {
	if ( x==1) {
		cout<<"milion ";
		return;
	}

	 dziesiatki(x);
	 if ( x >= 2 && x<=4) {
	 	cout<<"miliony ";
	 } else {
	 	cout<<"milionow ";
	 }
}

void tysiace ( int x) {
	if ( x==1) {
		cout<<"tysiac ";
	} else {
		if ( x==100) {
			cout<<"sto tysiecy";
		} else {
			if ( x<10) {
				if ( x<=4) {
					cout<<od1do9[x]<<" "<<"tysiace ";
				} else {
					cout<<od1do9[x]<<" "<<"tysiacy ";
				}
				
			} else {
			
			if ( x>=10 && x<=99) {
			dziesiatki(x);
			} else {
				cout<<od200do900[x/100-1]<<" ";
				if ( x%100>=10) {
					dziesiatki(x);
				} 
				else {
					if ( x%100>=1 && x%100<=9) {
						cout<<od1do9[x]<<" ";
					}
				}
				
			}
			cout<<"tysiecy ";
		}
		}
		
	}
}

void sety ( int x) {
	if ( x<100) {
		if ( x>=10) {
			dziesiatki(x);
		} else {
			if (x!=0) {
				cout<<od1do9[x]<<" ";
			}
			
		}
	} else {
		
	if ( x==100) {
		cout<<"sto ";
	} else {
		if ( x/100==1) {
			cout<<"sto ";
			dziesiatki(x%100);
		} else {
			cout<<od200do900[x/100-1]<<" ";
			dziesiatki(x%100);
		}
		
		
	}
}
}


void dziesiatki ( int x) {
	if ( x!=0) {
	if ( x/10 == 1) {
		cout<<od10do19[x%10]<<" ";
	} else {
		if ( x%10==0) {
			cout<<od20do90[x/10-1]<<" ";
		}
		if ( x/10==0 &&  x%10!=0) {
			
			cout<<od1do9[x/10]<<" ";
		} else {
			assert ( x/10!=0);
			assert ( x%10!=0);
				cout<<od20do90[x/10-1]<<" ";
				cout<<od1do9[x%10]<<" ";
		}
		
	}
}
}

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);
  int n;
  cin>>n;
  if ( n>=1000000) {
  	miliony ( n/1000000);
  } 
  	n=n%1000000;
  	if ( n>=1000) {
  		tysiace( n/1000);
	  }
	   	n=n%1000;
	   
	  	sety (n);
}

//b³edy 999999
