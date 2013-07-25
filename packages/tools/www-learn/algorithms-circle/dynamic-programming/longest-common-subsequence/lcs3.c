// Longest Common Subsequence
//
// See also: http://wordaligned.org/articles/longest-common-subsequence
//
// Note that, now, the differences are at the character level,
// At the word level, it would be nice for showing diffs of text/stx revisions.


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXLEN 100

#define max(a,b) (a)<(b)?(b):(a)
#define min(a,b) (a)<(b)?(a):(b)

#define NEITHER     0
#define UP          1
#define LEFT        2
#define UP_AND_LEFT 3

void lcs_lens(const char *xs, const char *ys, int *lengths, int back[MAXLEN][MAXLEN]) {

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

    for (j = 0; j < n; ++j) {
      if (xs[i] == ys[j]) {
	// up and left
	curr[j+1] = prev[j] + 1;
	back[i][j] = UP_AND_LEFT;
      } else {
	if (curr[j] > prev[j+1]) {
	  // left
	  curr[j+1] = curr[j];
	  back[i][j] = LEFT;
	} else {
	  // up
	  curr[j] = prev[j+1];
	  back[i][j] = UP;
	}
      }
    }

    for (j = 0; j <= n; ++j)
      printf("%d,",curr[j]);
    printf("\n");

  }


  for (j = 0; j <= n; ++j) {
    lengths[j] = curr[j];
  }

  free(prev);
  free(curr);

}


  



int main(int argc, char *argv[]) {

  if (argc < 3) {
    printf("usage: %s seq1 seq2\n",argv[0]);
    exit(-1);
  }

  int i,j;
  int m = strlen(argv[1]);
  int n = strlen(argv[2]);

  int *lengths = (int *) malloc ( (n+1) * sizeof(int));
  int back[MAXLEN][MAXLEN]; // do some fancy memory allocation stuff with this backtracking array


  printf("LCS(%s,%s)\n",argv[1],argv[2]);

  lcs_lens(argv[1], argv[2], lengths,back);

  printf("Length of LCS = %d\n", lengths[n]);



  for (i=0;i<m;++i) {
    for (j=0;j<n;++j) {
      printf("%d",back[i][j]);
    }
    printf("\n");
  }

  // print all
  int longest_length = lengths[n];
  char *lcs = (char *) malloc( 1+longest_length * sizeof(char));
  int k, pos;
  for (k=n; k>0; --k) {
    printf("k=%d lengths[k]=%d\n",k,lengths[k]);
    if (lengths[k] == lengths[n]) {
      pos = lengths[n];
      //for(i=0;i<n;i++) lcs[i]=' ';
      lcs[pos--]='\0';
      i = m-1;
      //j = k-1;
      j = n-1;
      while (i>=0 && j>=0) {
	printf("%d,%d = %d %c\n",i,j,back[i][j],argv[1][i]);
        if (back[i][j] == UP_AND_LEFT) {
          //printf("%c",x[i-1]);
          lcs[pos--] = argv[1][i];
          --i;
          --j;
        } else if (back[i][j] == LEFT) {
	  printf("+%c\n",argv[2][j]); // chars added to left word
          --j;
        } else if (back[i][j] == UP) {
	  printf("-%c\n",argv[1][i]); // chars removed from left word
          --i;
        } else {
	  // error
	  printf("error");
	  break;
	}
      }
      printf("%s\n",lcs);
      break;
    }
  }







  free(lengths);

  return 0;
}
