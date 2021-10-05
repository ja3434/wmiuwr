void merge1(long src1[], long src2[], long dest[], long n) {
  long i1 = 0, i2 = 0;
  while (i1 < n && i2 < n)
    *dest++ = src1[i1] < src2[i2] ? src2[i1++] : src2[i2++];
}

void merge2(long src1[], long src2[], long dest[], long n) {
  long i1 = 0, i2 = 0;
  while (i1 < n && i2 < n) {
    int i1_c = i1, i2_c = i2;
    int x = (src1[i1] < src2[i2]);
    *dest++ = x * src2[i1] + (x^1) * src2[i2];
    i1 += x;
    i2 += x^1;
  }
}