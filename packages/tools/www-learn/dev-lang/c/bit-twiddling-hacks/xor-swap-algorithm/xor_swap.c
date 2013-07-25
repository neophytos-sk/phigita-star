// swap two numbers without using temporary variable

#include <stdio.h>

void xor_swap(int *x, int *y) {
  if (x!=y) {
    *x ^= *y;  // x = x xor y
    *y ^= *x;  // y = x xor y
    *x ^= *y;  // x = x xor y
  }
}


int main() {
  int x = 5;
  int y = 17;
  xor_swap(&x,&y);
  printf("(after swap) x=%d, y=%d\n",x,y);
  return 0;
}
