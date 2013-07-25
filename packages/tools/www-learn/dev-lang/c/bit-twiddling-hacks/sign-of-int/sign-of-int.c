#include <stdio.h>
#include <limits.h>

int sign(int v) {

  // we want to find the sign of v
  int sign;   // the result goes here 

  // CHAR_BIT is the number of bits per byte (normally 8).
  sign = -(v < 0);  // if v < 0 then -1, else 0. 

  // or, to avoid branching on CPUs with flag registers (IA32):
  sign = -(int)((unsigned int)((int)v) >> (sizeof(int) * CHAR_BIT - 1));

  // or, for one less instruction (but not portable):
  sign = v >> (sizeof(int) * CHAR_BIT - 1); 

  return sign;

}

int main(){

  printf("CHAR_BIT=%d\n",CHAR_BIT);
  printf("sign(-5) = %d\n",sign(-5));
  printf("sign(7) = %d\n",sign(7));

  return 0;

}
