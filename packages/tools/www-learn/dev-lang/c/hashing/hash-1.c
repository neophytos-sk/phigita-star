#include <stdio.h>


/* This implementation of a hash function for string keys involves one
 * multiplication and one addition per character in the key. if we were to
 * replace the constant 127 by 128, the program would simply compute the
 * remainder when the number corresponding  to the 7-bit ASCII representation
 * of the key was divided by the table size, using Horner's method. The prime 
 * base 127 helps us to avoid anomalies if the table size is a power of 2 or a 
 * multiple of 2.
 */
int hash(char *v, int M)
{
  int h = 0;
  int a = 127;

  // We can get our result without ever carrying a large accumulated value,
  // because we can cast out multiples of M at any point during this computation
  // ---we need to keep only the remainder modulo M each time that we do a
  // multiply and add--- and we get the same result as we would if we had the 
  // capability to compute the long number, then do the division
  // (see exercise 14.10 in Sedgewick's book "Algorithms in C++ Parts 1-4".
  //
  // Prove that (((ax) mod M) + b) mod M = (ax+b) mod M, assuming
  // that a,b,x, and M are all nonnegative integers.
  for(; *v!=0; v++)
    h = (a*h + *v) % M;


  return h;
}

/* Universal hash function (for string keys)
 * This function does the same computations as above, but using pseudorandom
 * coefficient values instead of a fixed radix, to approximate the ideal of
 * having a collision between two given nonequal keys occur with probability
 * 1/M. We use a crude random-number generator to avoid spending extensive
 * time on computing the hash function.
 */
int hashU(char *v, int M)
{
  int h, a = 31415, b = 27183;
  for(h=0; *v != 0; v++, a = a*b % (M-1))
    h = (a*h + *v) % M;
  return (h < 0) ? (h + M) : h;
}
	

int main()
{
  char *v[] = {"hello", "world", "neophytos", "demetriou"};
  int M = 96; // our table/array size
  int i;
  for(i=0;i<4;++i)
    printf("hash: %3d    hashU: %3d\n", hash(v[i],M), hashU(v[i], M) );
  return 0;
}
