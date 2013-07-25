/* Permutations of a string: Implement a function that prints all possible
 * orderings of the characters in a string. In other words, print all 
 * permutations that use all the characters from the original string. For 
 * instance, given the string "hat" your function should print the strings
 * "tha", "aht", "tah", "ath", "hta", and "hat". Treat each character in the
 * input string as a distinct character, even if it is repeated. Given the
 * string "aaa", your function should print "aaa" six times. You may print
 * the permutations in any order you choose.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Generate Permutations
void GenPerm(char *in, char *out, int *used, int length, int depth)
{
  int i;

  if (length == depth) {
    printf("%s\n",out);
    return;
  }

  for(i=0;i<length;++i) {
    if (!used[i]) {  // if used skip to the next letter
      out[depth]=in[i]; // put current letter in output
      used[i] = 1;      // mark this letter as used
      GenPerm(in,out,used,length,depth+1);
      used[i] = 0;      // umark this letter
      // out[depth] = '\0';
    }
  }
}

int permute(char *in)
{
  int length,i;
  char *out;
  int *used;

  length = strlen(in);

  out = (char *)malloc(sizeof(char)*length+1);
  if (!out)
    return 0;
  out[length+1] = '\0';

  used= (int *)malloc(sizeof(int) * length);
  if (!used)
    return 0;

  /* start with no letters used, so zero array */
  for(i=0;i<length;++i)
    used[i]=0;
  
  GenPerm(in,out,used,length,0);

  free(used);
  free(out);
  return 1; /* success */

}


int main(int argc, char *argv[])
{
  int i;
  for(i=1;i<argc;++i) {
    printf("Generating Permutations for: %s\n",argv[i]);
    printf("============================\n");
    permute(argv[i]);
  }

  return 0;
}
