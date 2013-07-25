/* Combination of a string: implement a function that prints all possible
 * combinations of the characters in the string. These combinations range in
 * length from one to the length of the string. Two combinations that differ
 * only in ordering of their characters are the same combination. In other
 * words "12" and "31" are different combinations from the input string "123",
 * but "21" is the same as "12".
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void GenComb(char *in, char *out, int length, int depth, int start)
{

  if (start == length) {
    // if (depth==2) printf("out=%s\n",out);
    return;
  }

  int i;
  for(i=start;i<length;++i) {
    out[depth]=in[i];       // select current letter
    out[depth+1] = '\0';    // tack on NUL for printf
    printf("%s\n",out);     // print this combination
    //    if (i < length -1)      // recurse if more letters in input
    GenComb(in,out,length,depth+1,i+1);
  }
}


int Combinations(char *in)
{

  int length,i;
  char *out;

  length = strlen(in);
  out = (char *) malloc(length+1);
  if (!out)
    return 0; // failure

  GenComb(in, out, length, 0, 0);

  free(out);
  return 1; // success

}


int main(int argc, char *argv[])
{
  int i;
  for(i=1;i<argc;++i) {
    printf("Generating Combinations for: %s\n",argv[i]);
    printf("============================\n");
    Combinations(argv[i]);
  }

  return 0;

}
