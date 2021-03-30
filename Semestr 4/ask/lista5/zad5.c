#include <stdio.h>
#include <stdint.h>

long switch_prob(long rdi, long rsi) {
    static void *array[] = { &&L1, &&L1, &&L2, &&L3, &&L4, &&L5 };
    long rax;
    rsi -= 0x3c;
    if (rsi > 0x5) {
        goto L3;
    }
    goto *array[rsi];
L1:
    rax = rdi * 8;
    return rax;
L4:
    rax = rdi;
    rax >>= 3;
    retun rax;
L2:
    rax = rdi;
    rax <<= 4;
    rax -= rdi;
    rdi = rax;
L5:
    rdi *= rdi;
L3:
    rax = 0x4b + rdi;
    return rax;
}

long decode(long x, long n) {
    long result;
    n -= 0x3c;
    switch (n)
    {
    case 0:
    case 1:
        return x + 8;
    case 4:
        return x >> 3;
    case 2:
        result = (x << 4) - x;
        x = result;
    case 5:
        x *= x;
    case 3:
    default:
        return 0x4b + x;    
    }
}

int main() {
    
}