#include <stdint.h>
#include <stdio.h>


static const int S[] = {1, 2, 4, 8, 16}; // Magic Binary Numbers
static const int B[] = {0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF, 0x0000FFFF};

char* utb(uint32_t x) {
  static char rep[36];
  int cnt = 34;
  for (int i = 0; i < 32; i += 1) {
    if (i > 0 && i % 8 == 0) {
      rep[cnt] = ' ';
      cnt -= 1;
    }
    rep[cnt] = (x & 1) + '0';
    cnt -= 1;
    x >>= 1;
  }
  rep[35] = '\0';
  return rep;
}

void pb(uint32_t x) {
  printf("%s    : %d\n", utb(x), x);
}

struct A {
  int8_t a;
  void *b;
  int8_t c;
  int16_t d;
};

struct B {
  void *c;
  double b;
  int16_t a;
};

struct C {
  int8_t a;
  int8_t c;
  int16_t d;
  void *b;
};

// zaklada count > 0
void secret(uint8_t *to, uint8_t *from, size_t count) {
  size_t n = (count + 7) / 8;
  switch (count % 8) {
    case 0: do {  *to++ = *from++;
    case 7:       *to++ = *from++;
    case 6:       *to++ = *from++;
    case 5:       *to++ = *from++;
    case 4:       *to++ = *from++;
    case 3:       *to++ = *from++;
    case 2:       *to++ = *from++;
    case 1:       *to++ = *from++;
               } while (--n > 0);
  }
}

// zaklada count > 0
void goto_secret(uint8_t *to, uint8_t *from, size_t count) {
  size_t n = (count + 7) / 8;
  static void *array[] = { &&finito, &&c0, &&c1, &&c2, &&c3, &&c4, &&c5, &&c6, &&c7 };
  goto *array[count % 8 + 1];
  c0: *to++ = *from++;
  c7: *to++ = *from++;
  c6: *to++ = *from++;
  c5: *to++ = *from++;
  c4: *to++ = *from++;
  c3: *to++ = *from++;
  c2: *to++ = *from++;
  c1: *to++ = *from++;
  goto *array[(--n > 0)];
  finito: return;
}

int main() {
  /* Zadanie 1 */
  printf("Zadanie 1:\n");

  uint32_t i = 7, k = 15, x = 15689126;

  pb(x);
  uint32_t c = (((1<<i) & x) >> i) << k;        // 0010 0000
  x = (x & ~(1<<k)) | c;
  pb(x);


  /* Zadanie 2 */
  printf("Zadanie 2:\n");

  uint32_t v = 312866134;
  pb(v);

  // wersja prosta
  c = v - ((v >> 1) & B[0]);              pb(c);
  c = ((c >> S[1]) & B[1]) + (c & B[1]);  pb(c);
  c = ((c >> S[2]) + c) & B[2];           pb(c);
  c = ((c >> S[3]) + c) & B[3];           pb(c);
  c = ((c >> S[4]) + c) & B[4];           pb(c);
  printf("-----------------\n");
  // wersja dla koksow
  v = v - ((v >> 1) & 0x55555555);                    pb(v);// reuse input as temporary
  v = ((v >> 2) & 0x33333333) + (v & 0x33333333);     pb(v); // temp
  c = ((v + (v >> 4) & 0xF0F0F0F) * 0x1010101) >> 24; pb(c); // count
  

  /* Zadanie 3 */
  printf("Zadanie 3:\n");
  
  struct A a;
  struct B b;
  struct C d;
  int8_t x1;
  void *x2;
  int16_t x3;
  printf("%lu %lu %lu\n", sizeof x1, sizeof x2, sizeof x3);
  printf("%lu %lu %lu\n", sizeof a, sizeof b, sizeof d);


  /* Zadanie 4 */


  /* Zadanie 5 */

  /* s += b[j + 1] + b[--j];
   * 
   * t1 := j + 1
   * t2 := t1 * 4
   * t3 := b[t2]
   * j := j - 1
   * t4 := j * 4
   * t5 := b[t4]
   * t6 := t4 + t5   // Czy na pewno tak?
   * s := s + t6
   * 
   * a[i++] -= *b * (c[j*2] + 1);
   * 
   * t1 := *b
   * t2 := j * 2
   * t3 := t2 * 4
   * t4 := c[t3]
   * t5 := t4 + 1
   * t6 := t1 * t5
   * a := a - t6
   * i := i + 1
   */

  /* Zadanie 6 */
  /* vs->d = us[1].a + us[j].c;
   * t1 := 1 * 12
   * t2 := us + t1
   * t2' := us + 0     // chcemy dostać się do a, ale jest na poczatku, wiec nic dodawac nie trzeba
   * t3 := *t2
   * t4 := j * 12
   * t5 := us + t4
   * t6 := t5 + 8
   * t7 := *t6
   * t8 := t3 + t7
   * t9 := vs + 9
   * *t9 := t8
   */

  /* Zadanie 7 */
 
   /*       I := 0                      ; <<B1>>
            goto ITest        
    ILoop:  J := I                      ; <<B2>>
            goto WTest
    WLoop:  t1 := 4 * J                 ; <<B3>>
            Temp := arr[t1]             ; arr[J]
            t2 := J - 1        
            t3 := 4 * t2
            t4 := arr[t3]               ; arr[J - 1]
            arr[t1] := t4               ; arr[J] := arr[J - 1]
            arr[t3] := Temp             ; arr[J - 1] := Temp
            J := J - 1
    WTest:  if J <= 0 goto IPlus        ; <<B4>>
            t4 := 4 * J                 ; <<B5>>
            t5 := arr[t4]
            t6 := J - 1
            t7 = 4 * t6
            t8 := arr[t7]
            if t5 >= t8 goto IPlus
            goto WLoop                  ; <<B6>>
    IPlus:  I := I + 1                  ; <<B7>>
    ITest:  if I < length goto ILoop    ; <<B8>>
   */ 


  /* Zadanie 8 */
  printf("Zadanie 8:\n");
  
  // secret kopiuje wartości na które wskazuje from do miejsca w które wskazuje to,
  // przesuwa oba wskaźniki i powtarza tak count razy (czyli efektywnie kopiuje np. tablice)

  uint8_t t1[10] = {1,2,3,0,5,100,7,8,9,10}, t2[10];
  uint8_t* to = t2 + 2, *from = t1 + 3;
  size_t count = 4;

  goto_secret(to, from, count);
  
  for (int i = 0; i < 10; i++)
    printf("%hhd ", t1[i]);
  printf("\n");
  for (int i = 0; i < 10; i++)
    printf("%hhd ", t2[i]);
  printf("\n");

}