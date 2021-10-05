#include <stdio.h>
#include <stdint.h>

int main() {
    int32_t x = 0xc0000000;
    int32_t y = x + x;

    printf("%d, %d\n", x, y);
}