#include <cstdio>
#include <algorithm>
using namespace std;
#define rand_mod 1000000033
int rozm, zapy, ds[200000], dl;
typedef long long LL;
LL sum, wcz[200000], rand_plus, ele[6];
bool cmp(int x, int y)
{
	return wcz[x] < wcz[y];
}
int main()
{
	scanf("%d%Ld", &rozm, &rand_plus);
	scanf("%d", &zapy);
	for (int i = 0; i < zapy; ++i)
	{
		scanf("%Ld%Ld", wcz + 2 * i, wcz + 2 * i + 1);
		--wcz[2 * i];
	}
	for (int i = 0; i < 2 * zapy; ++i)
		ds[i] = i;
	sort(ds, ds + 2 * zapy, cmp);
	while (dl < 2 * zapy && !wcz[ds[dl]])
		++dl;

	for (int i = 1; i <= rozm; ++i)
	{
    ele[0] = (ele[1] * ele[1]) % rand_mod;
    ele[0] += ((ele[2] + ele[3]) * (ele[2] + ele[3])) % rand_mod;
    ele[0] += (ele[4] * ele[5]) % rand_mod;
    ele[0] += (rand_plus * rand_plus) % rand_mod;
    ele[0] += i % rand_mod;
    ele[0] %= rand_mod;
		sum += ele[0];
		while (dl < 2 * zapy && wcz[ds[dl]] == i)
			wcz[ds[dl++]] = sum;
    for (int i = 4; i >= 0; i--) ele[i+1] = ele[i];
    ele[0] = 0;
	}
	for (int i = 0; i < zapy; ++i)
		printf("%Ld\n", wcz[2 * i + 1] - wcz[2 * i]);
  return 0;
}
