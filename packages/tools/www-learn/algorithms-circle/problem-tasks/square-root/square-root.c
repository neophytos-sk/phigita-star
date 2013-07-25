#include <stdio.h>

double square_root(double x) {
  double guess = x/2;
  double prev_guess;
  do {
    prev_guess = guess;
    printf("guess=%f\n",guess);
    guess = (guess + x/guess)/2;
  } while (prev_guess - guess > 1e-10);
  return guess;
}


int main(int argc,char *argv[]) {
  printf("square root of 25 = %f\n",square_root(25));
  return 0;
}
