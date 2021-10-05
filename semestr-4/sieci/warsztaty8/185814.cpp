#include <bits/stdc++.h>
using namespace std;

string Jedn[] = {"","jeden","dwa","trzy","cztery","piec","szesc","siedem","osiem","dziewiec"};
string Nasc[] = {"dziesiec","jedenascie","dwanascie","trzynascie","czternascie","pietnascie","szesnascie","siedemnascie","osiemnascie","dziewietnascie"};
string Dzie[] = {"","","dwadziescia","trzydziesci","czterdziesci","piecdziesiat","szescdziesiat","siedemdziesiat","osiemdziesiat","dziewiecdziesiat"};
string Setk[] = {"","sto","dwiescie","trzysta","czterysta","piecset","szescset","siedemset","osiemset","dziewiecset"};

string fragment(int liczba){
    string ret;
    int s = liczba/100, d = (liczba/10)%10, j = liczba%10;
    ret += Setk[s];
    if(Setk[s] != "") ret += " ";

    if(d == 1) ret += Nasc[j];
    else{
        ret += Dzie[d];
        if(Dzie[d] != "") ret += " ";
        ret += Jedn[j];
    } 
    return ret;
}

string miliony(int ile){
    if(ile == 0) return "";
    if(ile == 1) return "milion";
    int d = ile%10, j = (ile/10)%10;
    if((d >= 2 && d <= 4) && j != 1) return "miliony";
    return "milionow";
}

string tysiace(int ile){
    if(ile == 0) return "";
    if(ile == 1) return "tysiac";
    int d = ile%10, j = (ile/10)%10;
    if((d >= 2 && d <= 4) && j != 1) return "tysiace";
    return "tysiecy";
}

int main(){
    int n;
    string wyr;
    cin >> n;
    int mln = n/1000000, tys = (n/1000)%1000, jed = n%1000;

    if(n == 0){
        cout << "zero";
        return 0;
    }
    
    wyr = fragment(mln);
    if(wyr != "jeden") cout << wyr;
    if(wyr != "" && wyr != "jeden") cout << " ";
    cout << miliony(mln);
    if(wyr != "") cout << " ";

    wyr = fragment(tys);
    if(wyr != "jeden") cout << wyr;
    if(wyr != "" && wyr != "jeden") cout << " ";
    cout << tysiace(tys);
    if(wyr != "") cout << " ";

    cout << fragment(jed);
}