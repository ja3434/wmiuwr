#include <stdint.h>
#include <stdio.h>

const uint64_t C[] = {
    0x5555555555555555LL,
    0x3333333333333333LL,
    0x0f0f0f0f0f0f0f0fLL,
    0x00ff00ff00ff00ffLL,
    0x0000ffff0000ffffLL,
    0x00000000ffffffffLL
};

uint64_t revbits(uint64_t x) {
    x = ((x & C[0]) << 1) | ((x >> 1) & C[0]);
    x = ((x & C[1]) << 2) | ((x >> 2) & C[1]);
    x = ((x & C[2]) << 4) | ((x >> 4) & C[2]);
    x = ((x & C[3]) << 8) | ((x >> 8) & C[3]);
    x = ((x & C[4]) << 16) | ((x >> 16) & C[4]);
    x = ((x & C[5]) << 32) | ((x >> 32) & C[5]);
    return x;
}