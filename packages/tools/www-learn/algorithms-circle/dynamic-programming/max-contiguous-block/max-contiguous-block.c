#include <stdio.h>
#include <stdlib.h>

#define MAX_N 1000

int max_contiguous_block(unsigned char grid[MAX_N][MAX_N],n,m) {
  if (n==1 && m==1) {
  } else if (n==1) {
  } else if (m==1) {
  }

  // max_contiguous_block(grid,n/2,m/2);
  // max_contiguous_block(slice(grid,n/2,m/2),n,m);

}

int main(int argc, char *argv[]) {

  int i=0,j=0;
  unsigned char grid[MAX_N][MAX_N];
  size_t m,n;

  FILE *fp = fopen("city_grid.txt","r");
  while (!feof(fp)) {
    unsigned char ch = getc(fp);
    if (ch == ' ') continue;
    if (ch == '\n') {
      ++i;
      m=j;
      j=0;
      continue;
    } else {
      grid[i][j]=ch;
      ++j;
    }
  }
  n = i;
  fclose(fp);

  int result = max_contiguous_block(grid,n,m);

  /*
  for(i=0;i<n;++i) {
    for(j=0;j<m;++j) {
      printf("%c",grid[i][j]);
    }
    printf("\n");
  }
  */

  printf("n=%zd m=%zd result=%d\n",n,m,result);

  return 0;
}
