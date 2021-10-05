#include <bits/stdc++.h>
using namespace std;

string jednosci[20] = {"", "jeden ", "dwa ", "trzy ", "cztery ", "piec ", "szesc ", "siedem ", "osiem ", "dziewiec "};
string setki[20] = {"", "sto ", "dwiescie ", "trzysta ", "czterysta ", "piecset ", "szescset ", "siedemset ", "osiemset ", "dziewiecset "};
string dziesiatki[20] = {"", "", "dwadziescia ", "trzydziesci ", "czterdziesci ", "piecdziesiat ", "szescdziesiat ", "siedemdziesiat ", "osiemdziesiat ", "dziewiecdziesiat "};
string nastki[20] = {"dziesiec ", "jedenascie ", "dwanascie ", "trzynascie ", "czternascie ", "pietnascie ", "szesnascie ", "siedemnascie ", "osiemnascie ", "dziewietnascie "};
string mil[20] = {"milionow ", "milionow ", "miliony ", "miliony ", "miliony ", "milionow ", "milionow ", "milionow ", "milionow ", "milionow "};
string tys[20] = {"tysiecy ", "tysiecy ", "tysiace ", "tysiace ", "tysiace ", "tysiecy ", "tysiecy ", "tysiecy ", "tysiecy ", "tysiecy "};

string do_stu(int n) {
    string odp="";
    if(n!=0) {
        odp+=setki[n/100];
        int dzies=(n/10)%10;
        if(dzies!=1) {
            odp+=dziesiatki[dzies];
            odp+=jednosci[n%10];
        }
        else odp+=nastki[n%10];
    }
    return odp;
}

string miliony(int n) {
    string odp="";
    if(n==1) return "milion ";
    if(n==0) return "";
    odp+=do_stu(n);
    int dzies = (n/10)%10;
    if(dzies==1) odp+="milionow ";
    else odp+=mil[n%10];
    return odp;
}

string tysiace(int n) {
    string odp="";
    if(n==1) return "tysiac ";
    if(n==0) return "";
    odp+=do_stu(n);
    int dzies = (n/10)%10;
    if(dzies==1) odp+="tysiecy ";
    else odp+=tys[n%10];
    return odp;
}

int main () {
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    int n;
    cin>>n;
    if(n==0) {
        cout<<"zero";
        return 0;
    }
    string wynik= miliony(n/1000000)+tysiace((n/1000)%1000)+do_stu(n%1000);
    cout<<wynik;
}

