#include <stdio.h>

int main() {
  char buffer[1000];
  printf("Echo!\n");
  while (1) {
    scanf("%s", buffer);
    printf("%s\n", buffer);
  }
  printf("What?");
}
