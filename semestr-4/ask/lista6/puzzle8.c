#include <limits.h>

struct T {
    long min;
    long max;
    long mean;
};

struct T puzzle8(long *a, long n);

struct T decode(long *a, long n) {
    long maks = LONG_MIN;
    long mini = LONG_MAX;
    long sum = 0;
    for (int i = 0; i < n; i++) {
        if (maks < a[i]) maks = a[i];
        if (mini > a[i]) mini = a[i];
        sum += a[i]; 
    }
    struct T ret;
    ret.min = mini;
    ret.max = maks;
    ret.mean = sum / n;
    return ret;
}