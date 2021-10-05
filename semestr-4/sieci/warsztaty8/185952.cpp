#include<bits/stdc++.h>
using namespace std;

int tab[13]= {31,28,31,30,31,30,31,31,30,31,30,31};

int czas(string dt,string g)
{
    int lata,msc,dni;
    long long c1,c2;
    lata=dt[0]*1000+dt[1]*100+dt[2]*10+dt[3]-'0'*1111-1900;
    msc=dt[5]*10+dt[6]-11*'0';
    dni=0;
    c1=(dt[8]*10+dt[9]-11*'0'-1)*86400;
    c1+=(g[0]*10+g[1]-11*'0')*3600;
    c1+=(g[3]*10+g[4]-11*'0')*60;
    c1+=g[6]*10+g[7]-11*'0';
    for(int i=0; i<lata*12+msc-1; i++)
    {
        if(i%48==0 && dt[1]!=9  && dt[2]!=0  && dt[3]!=0)
        {
            c1+=86400;
        }
        c1+=tab[i%12]*86400;
    }
    return c1;
}
int main()
{
    long long wynik=0;
    string dt,g;
    cin >> dt >> g;
    long long w1=czas(dt,g);
    cin >> dt >> g;
    int n;
    cin >> n;
    long long w2=czas(dt,g);
    long long w=w2-w1;
    int d=w/86400;
    w%=86400;
    int h=w/3600;
    w%=3600;
    int m=w/60;
    w%=60;
    int s=w;
    if(d!=0)
    {
        cout << d << ' ';
        if(d==1)
        {
            cout << "dzien ";
        }
        else
        {
            cout << "dni ";
        }
    }
    if(h!=0)
    {
        cout << h << ' ';
        if(h==1)
        {
            cout << "godzina ";
        }
        else if(h%10>=2 && h%10<=4 && (h<=11 || h>=15))
        {
            cout << "godziny ";
        }
        else
        {
            cout << "godzin ";
        }

    }
    if(m!=0)
    {
        cout << m << ' ';
        if(m==1)
        {
            cout << "minuta ";
        }
        else if(m%10>=2 && m%10<=4 && (m<=11 || m>=15))
        {
            cout << "minuty ";
        }
        else
        {
            cout << "minut ";
        }

    }
    if(s!=0)
    {
        cout << s << ' ';
        if(s==1)
        {
            cout << "sekunda ";
        }
        else if(h%10>=2 && h%10<=4 && (h<=11 || h>=15))
        {
            cout << "sekundy ";
        }
        else
        {
            cout << "sekund ";
        }

    }
    cout << "\n";
}




