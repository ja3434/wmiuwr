#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int puzzle4(long *a, long v, uint64_t s, uint64_t e);

long tab[100];

int assembly_like(long *rdi, long rsi, uint64_t rdx, uint64_t rcx) {
    uint64_t rax = rcx;
    rax -= rdx;
    rax >>= 1;
    rax += rdx;
    if (rcx < rdx) {
        goto L5;
    }
    long r8 = *(rdi + rax*8);
    if (rsi == r8) {
        goto L10;
    } 
    if (rsi > r8) {
        goto L11;
    }
    rdx = rax + 1;
    assembly_like(rdi, rsi, rdx, rcx);
L10:
    return (int)rax;
L11:
    rcx = rax - 1;
    assembly_like(rdi, rsi, rdx, rcx);
    return (int)rax;
L5:
    return -1;
}


// binsearch :)
int decode(long *a, long v, uint64_t s, uint64_t e) {
    int result = (e + s) / 2;
    if (e < s) {
        return -1;
    }
    long val = a[result];
    if (v == val) {
        return result;
    } 
    if (v < val) {
        e = result - 1;
    }
    else {
        s = result + 1;
    }
    return decode(a, v, s, e);
}

int main() {
    uint64_t n;
    long v;
    scanf("%ld %ld", &n, &v);
    for (int i = 0; i < n; i++) {
        scanf("%ld", &tab[i]);
    }
    printf("%d\n", puzzle4(tab, v, 0, n-1));
    printf("%d\n", decode(tab, v, 0, n-1));

}