#include <stdio.h>
#include <stdint.h>

uint8_t victim(uint8_t s) {
  s |= ((s & 0x55) << 1) | (s & 0xaa >> 1);
  return ((s >> 2) && 1) | ((s >> 4) && 2) | ((s >> 6) && 3);
}

uint8_t update(uint8_t s, uint8_t v) {
  int8_t p0 = victim(s);
  int8_t p1 = victim(s ^ 0b01010101);
  int8_t p2 = victim(s ^ 0b10101010);
  int8_t p3 = victim(s ^ 0b11111111);
  uint8_t age = (3 << (v << 1)) & s;

  s -= (~((char)(age - 1) >> 7)) & (1 << (p1 << 1));
  s -= (~((char)(age - 2) >> 7)) & (1 << (p2 << 1));
  s -= (~((char)(age - 3) >> 7)) & (1 << (p3 << 1));
  s |= (3 << (v << 1));
  return s;
}

int main() {}