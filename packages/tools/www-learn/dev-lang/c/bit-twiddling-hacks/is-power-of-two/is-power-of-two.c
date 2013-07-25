#include <stdio.h>

// Determining if an integer is a power of 2

int is_power_of_two(unsigned int v) {
  // we want to see if v is a power of 2
  int f;         // the result goes here 

  // f = (v & (v - 1)) == 0;
  // Note that 0 is incorrectly considered a power of 2 here. To remedy this, use:

  f = v && !(v & (v - 1));

  return f;

}

int main() {

  printf("%d\n",is_power_of_two(17));
  printf("%d\n",is_power_of_two(16));

  return 0;

}
