/* 
 * C[p] = minimum number of coins of denominations d[1],d[2],...,d[k] needed 
 * to make change for p cents.
 *
 */

#include <stdio.h>

#define INF 9999
#define MAX 1000

int C[MAX];
int S[MAX];
int d[100]; // = {20,10,5,1}


void change(int k, int n)
{
  int min,coin,p, i;
  int total;

  for (p=1; p<=n; p++){
    min = INF;
    for (i=0; i<k;i++){
      if (d[i] <= p)
	if (1+C[p-d[i]] < min) {
	  min = 1+C[p-d[i]];
	  coin = i;
	}
    }
    C[p]=min;
    S[p]=coin;
  }
}

void make_change(int n)
{
  while (n>0){
    printf("D_%d = %d\n",S[n],d[S[n]]);
    n=n-d[S[n]];
  }
}

int
main(int argc, char **argv)
{
  int n, k, i;

  printf("Amount for which change is to be made: ");
  scanf("%d",&n);

  printf("Number of denominations: ");
  scanf("%d",&k);
  for(i=0;i<k;i++) {
    printf("D_%d: ",i);
    scanf("%d",&d[i]);
    printf("%d\n",d[i]);
  }


  change(k,n);
  printf("-------\n");
  make_change(n);


  return 0;
}
