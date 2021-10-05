#include <cstdio>
#include <algorithm>
#include <cmath>
using namespace std;

#define EPS 0.000001

int main() {
	int numLiquids, reqCon, liquid[101];
	double sumSubst=0, sumLiquid=0, actCon;

	fill(liquid,liquid+101,0);

	scanf("%d%d",&numLiquids,&reqCon);

	for (int i=0;i<numLiquids;i++) {
		int con, amount;

		scanf("%d%d",&con,&amount);

		liquid[con]+=amount;
		sumSubst+=(double)(amount*con)/100;
		sumLiquid+=(double)amount;
	}

	if (sumLiquid==0) {
		printf("0.000\n");
		return 0;
	}

	actCon=(sumSubst/sumLiquid)*100;

	for (int i=0;i<=100;i++) {
		if ((actCon<(double)reqCon)&&(liquid[i]>0)) {
			double perc=(double)i/100, toSub=(double)((double)reqCon*sumLiquid-100*sumSubst)/((double)reqCon-(double)100*perc);
			
			toSub=min(toSub,(double)liquid[i]);

			sumLiquid-=toSub;
			sumSubst-=(toSub*i)/100;
		}
		if ((actCon>(double)reqCon)&&(liquid[100-i]>0)) {
			double perc=(double)(100-i)/100, toSub=(double)((double)reqCon*sumLiquid-100*sumSubst)/((double)reqCon-(double)100*perc);

			toSub=min(toSub,(double)liquid[100-i]);

			sumLiquid-=toSub;
			sumSubst-=(toSub*(100-i))/100;
		}
		
		if (sumLiquid==0) {
			printf("0.000\n");
			return 0;
		}
		actCon=(sumSubst/sumLiquid)*100;

		if (fabs((double)reqCon-actCon)<EPS)
			break;
	}
	
	printf("%.3lf\n",sumLiquid);

	return 0;
}
