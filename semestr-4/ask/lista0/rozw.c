#include <stdio.h>
#include <stdint.h>


int main() {
  /* Zad. 3 */ 

  uint32_t x, k;
  scanf("%d%d", &x, &k);

  x &= ~(1<<k);     // zerowanie k-tego bitu
  x |= (1<<k);      // ustawianie k-tego bitu
  x ^= (1<<k);      // swap k-tego bitu

  printf("%d\n", x);

  /* Zad. 4 */

  uint32_t y;
  scanf("%d%d", &x, &y);

  x <<= y;                    // x * 2^y
  x >>= y;                    // floor(x / 2^y)
  x &= (1<<y) - 1;             // x mod 2^y
  x = (x + (1<<y) - 1) >> y;  // ceil(x/2^y) = floor((x + 2^y - 1)/2^y)
  
  /* Zad. 5 */

  scanf("%d", &x);
  /* jesli x = 2^k, to x = 1000...0. Wtedy x - 1 = 0111...1, zatem x & (x - 1) == 0
   * gdy x jest potęgą dwójki. Łatwo widać, że jeśli x nie jest potęgą dwójki, 
   * to wiodący bit będzie ten sam, więc koniunkcja bitowa będzie niezerowa */
  printf("%d", (x & (x - 1)));  

  /* Zad. 6 */
  
  int rev = ((0xff000000 & x) >> 24u) |   // można pominąć tę koniunkcję.
            ((0xff0000 & x) >> 8u) | 
            ((0xff00 & x) << 8u) | 
            ((0xff & x) << 24u); 

  /* Zad. 7 */

  /* Kod sterujący - kod, który nie niesie informacji o znaku, ale niesie jakąś 
   * instrukcję sterującą dla urządzenia, np. do terminala.
   * ASCII (American Standard Code for Information Interchange) - zestaw znaków,
   * który stał się standardem w komunikacji elektronicznej.
   * 0, NUL - znak nie niosący żadnej informacji. Może informować np. o końcu danych tekstowych
   * 4, EOT (end of thread/end of transmission), ^D - informuje o końcu transmisji danych,
   * które mogły zawierać więcej niż jeden tekst.
   * 7, BEL (bell), ^G - instruuje urządzenie do wysłania dźwięku.
   * 10, LF (line feed), \n - instruuje urządzenie do przejścia do nowej linii, 
   * ale nie do jej początku. Z tego względu jest często wiązany z CR (carriage return), 
   * który instruuje urządzenie do powrotu do początku wiersza. W systemach UNIX sam \n
   * wystarczy.
   * 12, FF (Form feed) - instruuje np. drukarki do przejścia do pierwszego wiersza 
   * następnej kartkii.
   */

  /* Zad. 8 */

  /* UTF-8 (8-bit Unicode Transformation Format) - alternatywny zestaw znaków, 
   * w pełni kompatybilny z ASCII. Wykorzystuje od 1 do 4 bajtów do zakodowania 
   * pojedyńczego znaku. ASCII ma do dyspozycji jedynie 128 możliwych znaków, co 
   * zdecydowanie jest mniejsze niż potrzebna liczba znaków do zakodowania. 
   * Wykorzystanie 4 bajtów pozwala na gwałtowne zwiększenie tej liczby.
   * 
   * Proszę zapłacić 5€! ę - U+0119 (0000 0001 0001 1001), spacja - U+0020,
   * ł - U+0142 (0000 0001 0100 0010), € - U+20AC (0010 0000 1010 1100)
   * 01010000 01110010 01101111 01110011 01111010 [1100 0100 1001 1001] 
   * 00100000 
   * 01111010 01010001 01110000 [1100 0101 1000 0010] 01010001 01010011 01011001 [1100 0100 1000 0111]
   * 00100000
   * 00110101 [1110 0010 1000 0010 1010 1100] 00100001
   */ 

  return 0;
}