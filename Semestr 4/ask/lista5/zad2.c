#include <stdio.h>
#include <stdint.h>

long puzzle2(char *rdi /* rdi */, char *rsi /* rsi */) {
    char *rax = rdi;
L3:
    char r9b = *rax;
    char *r8 = rax + 1;
    char *rdx = rsi;
L2:
        char cl = *rdx;
        rdx++;
        if (cl == 0) {
            goto L4;
        }
        if (cl != r9b) {
            goto L2;
        }
        rax = r8;
        goto L3;
L4:
    return rax - rdi;
}


// funkcja sprawdza jaka jest pierwsza litera z s która nie występuje w d
// jesli wszystkie występują, to zwróci długość s.
long puzzle2_decoded(char *s /* rdi */, char *d /* rsi */) {
    for (char *result = s ; ; result++) {
        char first = *result;
        char *crawl = d;
        for (char *crawl = d; *crawl != first; crawl++) {
            if (*crawl == 0) {
                return result - s;
            }
        }
    }
}



int main() {

}