#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

uint32_t puzzle3(uint32_t n, uint32_t d);

// uint32_t divv(uint32_t edi, uint32_t esi) {
//     uint64_t rdi = edi;
//     uint64_t rsi = esi;
//     rsi <<= 32;
//     uint8_t edx = 32;
//     uint32_t ecx = 0x80000000;
//     uint32_t eax = 0;
// L3:
//     rdi += rdi;
//     int64_t r8 = rdi;
//     r8 -= rsi;
//     if (r8 < 0) {
//         goto L2;
//     }
//     eax |= ecx;
//     rdi = r8;
// L2:
//     ecx >>= 1;
//     edx--;
//     if (edx != 0) {
//         goto L3;
//     }
//     return eax;
// }

uint32_t decoded(uint32_t n, uint32_t d) {
    uint64_t N = n;
    uint64_t D = (uint64_t)d << 32;

    uint32_t bit = 0x80000000;
    uint32_t result = 0;
    for (uint32_t edx = 32; edx > 0; edx--) {
        N += N;
        if ((int64_t)(N - D) >= 0) {
            result |= bit;
            N -= D;
        }
        bit >>= 1;
    }
    return result;
}

int main() {
    for (uint32_t n=0; n <= 1000; ++n) {
        for (uint32_t d=1; d <= 1000; ++d) {
            if (puzzle3(n,d) != decoded(n, d)) {
                printf("%d %d\n", n, d);
                printf("%u %u\n", puzzle3(n, d), decoded(n, d));
                return 0;
            }
        }
    }
    printf("%d\n", puzzle3(1000000000, 2));
}