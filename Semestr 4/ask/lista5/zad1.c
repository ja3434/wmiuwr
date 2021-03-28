#include <stdio.h>
#include <stdint.h>

int puzzle(long x /* rdi */ , unsigned n /* rsi */) {
    if (n == 0) {
        return n;
    }
    int t = 0;              // edx := 0
    int result = 0;         // eax := 0
    do {
        int m = x & 0xffffffff;     // ecx := edi
        m &= 1;
        result += m;
        x >>= 1;
        t++;
    } while (t != n);
    return result;               // ????
}

int main() {
    long x;
    unsigned n;
    scanf("%ld%u", &x, &n);
    return puzzle(x, n);
}