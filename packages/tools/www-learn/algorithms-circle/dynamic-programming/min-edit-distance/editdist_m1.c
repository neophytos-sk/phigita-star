#include <stdio.h>
#include <string.h>

#define MAXLEN 1000

#define MIN3(x,y,z) (x)<=(y)&&(x)<=(z)?(x):((y)<=(x)&&(y)<=(z)?(y):(z))

/* a is a string of size n
 * b is a string of size m
 * Returns the minimum edit distance between strings a and b
 */
int MinEditDistance(const char *a, const char *b)
{
  int C[MAXLEN][MAXLEN], M[MAXLEN][MAXLEN];
  int i,j,n,m;

  n = strlen(a);
  m = strlen(b);

  for(i=0;i<=n;++i) C[i][0] = i;
  for(j=0;j<=m;++j) C[0][j] = j;

  int x,y,z;
  for(i=1;i<=n;++i) {
    for(j=1;j<=m;++j) {
      x = C[i-1][j] + 1;   // insert character
      y = C[i][j-1] + 1;   // delete character
      if ( a[i] == b[j] )
	z = C[i-1][j-1];   // characters match
      else
	z = C[i-1][j-1]+1; // replace character

      C[i][j] = MIN3(x,y,z);
      /* M[i][j] can be set appropriately:
       * if x is the min then 'I'
       * if y is the min then 'D'
       * if z (if branch) is the min then 'M'
       * if z (else branch) is the min then 'R'
       */
      printf("(%d,%d) x=%d y=%d z=%d C=%d\n",i,j,x,y,z,C[i][j]);

    }
  }
  return C[n][m];
}


int main(int argc, char *argv[])
{
  if (argc != 3) 
    printf("Usage: %s first_string second_string\n",argv[0]);

  int result = MinEditDistance(argv[1],argv[2]);
  printf("Minimum Edit Distance = %d\n", result);

  return 0;
}
