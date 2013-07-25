// Longest Common Subsequence
// TODO: Assumes for the input sequences that y is longer than x

#include <stdio.h>
#include <string.h>

#define MAXLEN 100

#define max(a,b) (a)<(b)?(b):(a)

#define NEITHER     0
#define UP          1
#define LEFT        2
#define UP_AND_LEFT 3

void LCS(const char *x, const char *y) {

  int i,j;
  size_t n,m;
  int C[MAXLEN][MAXLEN];
  int prev_lcs[MAXLEN][MAXLEN];

  m=strlen(x);
  n=strlen(y);
  for (i=0; i<=m; ++i) {
    for (j=0; j<=n; ++j) {
      C[i][j] = 0;
      prev_lcs[i][j] = NEITHER;
    }
  }

  for (i=1; i<=m; ++i) {
    for (j=1; j<=n; ++j) {
      if ( x[i-1] == y[j-1] ) {
	C[i][j] = C[i-1][j-1] + 1;
	prev_lcs[i][j] = UP_AND_LEFT;
	printf("%d,%d\n",i,j);
      } else {
	//C[i][j] = max(C[i][j-1],C[i-1][j]);
	if ( C[i][j-1] > C[i-1][j] ) {
	  C[i][j] = C[i][j-1];
	  prev_lcs[i][j] = LEFT;
	} else {
	  C[i][j] = C[i-1][j];
	  prev_lcs[i][j] = UP;
	}
      }
    }
  }

  printf("Length of LCS(%s,%s) = %d\n",x,y,C[m][n]);

  char lcs[MAXLEN];
  int k, pos;
  for (k=n; k>0; --k) {
    printf("k=%d C[m][k]=%d\n",k,C[m][k]);
    if (C[m][n] == C[m][k]) {
      pos = C[m][n];
      lcs[pos--]='\0';
      i = m;
      j = k;
      while (i>0 && j>0) {
	if (prev_lcs[i][j] == UP_AND_LEFT) {
	  //printf("%c",x[i-1]);
	  lcs[pos--] = x[i-1];
	  --i;
	  --j;
	} else if (prev_lcs[i][j] == LEFT) {
	  --j;
	} else if (prev_lcs[i][j] == UP) {
	  --i;
	}
      }
      printf("%s\n",lcs);
    }
  }
  
}


int main(int argc, char *argv[]) {
  char x[] = "BDCABA";
  char y[] = "ABCBDAB";

  LCS(x,y);

  return 0;
}
