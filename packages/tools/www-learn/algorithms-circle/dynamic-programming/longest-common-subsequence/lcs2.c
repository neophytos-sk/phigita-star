// Longest Common Subsequence

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXLEN 100

#define max(a,b) (a)<(b)?(b):(a)

#define NEITHER     0
#define UP          1
#define LEFT        2
#define UP_AND_LEFT 3

int lcs_lens(const char *xs, const char *ys) {

  int i,j,m,n;
  
  m = strlen(xs);
  n = strlen(ys);

  int *curr = (int *) malloc( (1+n) * sizeof(int));
  int *prev = (int *) malloc( (1+n) * sizeof(int));

  for (j = 0; j < n; ++j) {
    curr[j] = 0;
    prev[j] = 0;
  }

  for (i = 0; i <= m; ++i) {

    for (j = 0; j <= n; ++j)
      prev[j] = curr[j];

    for (j = 0; j < n; ++j)
      curr[j+1] = xs[i] == ys[j] ? prev[j] + 1 : max(curr[j],prev[j+1]);


    for (j = 0; j <= n; ++j)
      printf("%d,",curr[j]);
    printf("\n");

  }

  /*
  for (j = 0; j <= m; ++j) {
    lengths[j] = curr[j];
  }
  */
  int result;
  result = curr[n];

  free(prev);
  free(curr);

  return result;
}



int main(int argc, char *argv[]) {

  if (argc < 3) {
    printf("usage: %s seq1 seq2\n",argv[0]);
    exit(-1);
  }

  printf("length of lcs = %d\n", lcs_lens(argv[1],argv[2]));

  return 0;
}
