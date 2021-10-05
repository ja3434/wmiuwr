#include<iostream>
using namespace std;

int max_miesiac[12]={31,28,31,30,31,30,31,31,30,31,30,31};
string dzien[2]={"dzien","dni"};
string godziny[3]={"godzina","godziny","godzin"};
string minuty[3]={"minuta","minuty","minut"};
string sekundy[3]={"sekunda","sekundy","sekund"};

string wypisz(int a, char wyz)
{
    int dz=a/10;
    int j=a%10;
    if(wyz=='g'){
        if(j==1 and dz==0){
            return godziny[0];
        }else{
            if(j>=2 and j<=4 and (dz>=2 or dz==0)){
                return godziny[1];
            }else{
                return godziny[2];
            }
        }
    }
    if(wyz=='m'){
        if(j==1 and dz==0){
            return minuty[0];
        }else{
            if(j>=2 and j<=4 and (dz>=2 or dz==0)){
                return minuty[1];
            }else{
                return minuty[2];
            }
        }
    }
    if(wyz=='s'){
        if(j==1 and dz==0){
            return sekundy[0];
        }else{
            if(j>=2 and j<=4 and (dz>=2 or dz==0)){
                return sekundy[1];
            }else{
                return sekundy[2];
            }
        }
    }
    return "";
}

int main(){
int rok,mies,dni,godz,mi,sek;
long long time1=0,time2=0;
char p;
cin>>rok>>p>>mies>>p>>dni>>godz>>p>>mi>>p>>sek;
time1=time1+sek+(mi*60)+(godz*3600)+((dni-1)*86400);
for(int i=0;i<mies-1;i++){
    if(i==1 and (rok%4==0 and rok!=1900)){
        time1+=(29*86400);
    }else{
        time1+=(max_miesiac[i]*86400);
    }
}
for(int i=1900;i<rok;i++){
    if(i%4==0 and i!=1900){
        time1+=(366*86400);
    }else{
        time1+=(365*86400);
    }
}
cin>>rok>>p>>mies>>p>>dni>>godz>>p>>mi>>p>>sek;
cin>>p;
time2=time2+sek+(mi*60)+(godz*3600)+((dni-1)*86400);
for(int i=0;i<mies-1;i++){
    if(i==1 and (rok%4==0 and rok!=1900)){
        time2+=(29*86400);
    }else{
        time2+=(max_miesiac[i]*86400);
    }
}
for(int i=1900;i<rok;i++){
    if(i%4==0 and i!=1900){
        time2+=(366*86400);
    }else{
        time2+=(365*86400);
    }
}
time1=time2-time1;
dni=time1/86400;
godz=(time1/3600)%24;
mi=(time1/60)%60;
sek=time1%60;
if(dni>0){
    if(dni==1){
        cout<<dni<<" "<<dzien[0]<<" ";
    }else{
        cout<<dni<<" "<<dzien[1]<<" ";
    }
}
if(godz>0){
    cout<<godz<<" "<<wypisz(godz,'g')<<" ";
}
if(mi>0){
    cout<<mi<<" "<<wypisz(mi,'m')<<" ";
}
if(sek>0){
    cout<<sek<<" "<<wypisz(sek,'s')<<" ";
}
return 0;
}
