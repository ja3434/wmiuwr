#include <stdarg.h>
#include <stdio.h>

int wypisuj(int cnt, ...) {
    va_list v;
    va_start(v, cnt);
    int sum = 0;
    for (int i = 0; i < cnt; i++) {
        sum += va_arg(v, int);
    }
    return sum;
}

int puzzle7(int cnt, ...);

int main() {
    printf("%d\n", puzzle7(10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10));
}