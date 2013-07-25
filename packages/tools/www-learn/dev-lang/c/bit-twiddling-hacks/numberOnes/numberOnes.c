#include <stdio.h>


// O(n) where n is the number of bits in x
int numberOnes_M1 (int number)
{
  int count=0;
  while(number) { 
    if ( number & 1)
      ++count;
    number = number >> 1;
  }
  return count;
}

// O(m) where m is the number of 1s in x
// Notice that number-1 is the same as number 
// with the bits up to the first 1 flipped.
int numberOnes_M2 (int number)
{
  int count=0;
  while(number) {
    number = (number - 1) & number;
    ++count;
  }
  return count;
}


int main()
{
  int N[] = {57,137,22,255};
  int i;
  for (i=0;i<4;++i) // result from method 1 and 2 must be equal
    printf("M1:%d  M2:%d\n",numberOnes_M1(N[i]), numberOnes_M2(N[i]));
  return 0;
}
