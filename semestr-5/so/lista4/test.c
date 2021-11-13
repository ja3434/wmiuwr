#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  sleep(atoi(argv[1]));
  return atoi(argv[2]);
}
