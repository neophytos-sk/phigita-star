// greatest common divisor

#include <stdio.h>


inline int gcd(int a, int b)
{
  return b?gcd(b,a%b):a;
}


int main()
{
  printf("gcd(15,25)=%d\n",gcd(15,25));
  return 0;
}
