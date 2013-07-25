#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 1000

inline int min(x,y) { return x<y?x:y; }

/* a is a string of size n
 * b is a string of size m
 * Returns the minimum edit distance between strings a and b
 */
int MinEditDistance(const char *a, const char *b)
{
  int i,j,n,m;

  n = strlen(a);
  m = strlen(b);

  int *curr = (int *) malloc((m+1)*sizeof(int));
  int *prev = (int *) malloc((m+1)*sizeof(int));


  for(j=0;j<=m;++j) curr[j] = j;

  int x,y,z;
  for(i=1;i<=n;++i) {

    /* copy the previous cost matrix into prev */
    for(j=0;j<=m;++j) prev[j]=curr[j];

    curr[0] = i;

    for(j=1;j<=m;++j) {
      x = prev[j] + 1;    // insert character
      y = curr[j-1] + 1;  // delete character
      if ( a[i] == b[j] )
	z = prev[j-1];    // characters match
      else
	z = prev[j-1]+1;  // replace character

      curr[j] = min(x,min(y,z));
      /* int M[MAXLEN][MAXLEN];
       * M[i][j] can be set appropriately:
       * if x is the min then 'I'
       * if y is the min then 'D'
       * if z (if branch) is the min then 'M'
       * if z (else branch) is the min then 'R'
       */
      // printf("(%d,%d) x=%d y=%d z=%d C=%d\n",i,j,x,y,z,curr[j]);

    }
  }

  int result = curr[m];

  free(prev);
  free(curr);

  return result;
}


int main(int argc, char *argv[])
{
  if (argc != 3) {
    fprintf(stderr,"Usage: %s first_string second_string\n",argv[0]);
    return 1;
  }

  int result = MinEditDistance(argv[1],argv[2]);
  printf("Minimum Edit Distance = %d\n", result);

  return 0;
}
