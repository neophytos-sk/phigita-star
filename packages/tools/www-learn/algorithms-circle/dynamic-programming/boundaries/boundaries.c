// Given an input array of integers of size n, and a query array of integers of size k, find the smallest window of input array that contains all the elements of query array and also in the same order.

#include <stdio.h>

#define min(x,y) (x)<=(y)?(x):(y)
#define max(x,y) (x)<=(y)?(y):(x)

#define MAX 100


// P[j] is the position of the jth keyword in a given window [i,n) where 0<=i<n
int minWindow(int a[], int b[], int n, int m,int boundaries[])
{
  int minPos=n+1,maxPos=n+1,i,j,k,P[MAX];
  int nfound=0,minWin=-1;
  for(j=0;j<m;++j)
    P[j]=-1;

  printf("%d\n",nfound);

  for(i=0;i<n;++i) {
    nfound=0;
    minPos=n+1;
    maxPos=-1;
    for(j=0;j<m;++j) {
      printf(">>>>>>>>>>>>>> i=%d P[%d]=%d\n",i,j,P[j]);
      for(k=max(i,P[j]);k<n;++k) {
	if (a[k] == b[j]) {
	  P[j] = k;
	  nfound++;
	  minPos = min(minPos,k);
	  maxPos = max(maxPos,k);
	  break;
	}
      }
      printf("j=%d k=%d\n",j,k);
    }
    if (nfound < m) {
      printf("nfound after %d = %d (minWin=%d)\n",i,nfound,minWin);
      return minWin;
    }

    int win = maxPos - minPos;
    if (minWin==-1 || win<minWin) {
      boundaries[0]=minPos;
      boundaries[1]=maxPos;
      minWin=win;
    }
    printf("i=%d minPos=%d\n",i,minPos);
    i=minPos;
  }
  printf("minWindow=%d\n",minWin);
  return minWin;
}


int main() {
  int N[] = {23,46,24,16,16,29,35,2,77,29,35,77,29,2};
  int K[] = {16,2,77,29};
  int boundaries[2];

  int lenN, lenK;
  lenN = 14;
  lenK = 4;

  boundaries[0]=-1;
  boundaries[1]=-1;
  minWindow(N,K,lenN,lenK,boundaries);
  printf("from %d to %d\n",boundaries[0],boundaries[1]);
}
