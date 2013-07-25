/*
 *  Reverse bits of an unsigned integer.
 */

typedef unsigned int uint;
uint swapBits(uint x, uint i, uint j) {
  uint lo = ((x >> i) & 1);
  uint hi = ((x >> j) & 1);
  if (lo ^ hi) {
    x ^= ((1U << i) | (1U << j));
  }
  return x;
}
 
uint reverseXor(uint x) {
  uint n = sizeof(x) * 8;
  for (uint i = 0; i < n/2; i++) {
    x = swapBits(x, i, n-i-1);
  }
  return x;
}
