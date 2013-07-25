#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 110000

typedef long long ll;

void PrintArray(const int A[],int from, int to)
{
  int i;
  for(i=from;i<=to;++i)
    printf("%d ",A[i]);
  printf("\n");
}

ll Merge_and_CountSplitInv(int a[],int lower, int center, int upper, int temp[])
{
  ll count=0;
  int i=lower,j=center+1, k=lower;

  // merge the two sorted subarrays to temp
  while(i<=center && j<=upper) {
    if (a[i] <= a[j]) {
      temp[k] = a[i];
      i++;
    } else {
      temp[k] = a[j];
      j++;
      count += center-i+1; /*remaining*/
    }
    k++;
  }



  // if either pointer hits the end of its subarray before the other,
  // the remaining values are simply copied from the remaining subarray
  while(i<=center) {
    temp[k] = a[i];
    ++i;
    ++k;
  }
  while(j<=upper) {
    temp[k] = a[j];
    ++j;
    ++k;
  }

  return count;

}

ll Sort_and_Count(int a[], int lower, int upper)
{

  if (upper == lower)
    return 0;


  int temp[MAX];

  int center = (lower + upper)/2;

  ll x = Sort_and_Count(a,lower,center);
  ll y = Sort_and_Count(a,center+1,upper);

  // merge the two sorted subarrays into temp
  ll z = Merge_and_CountSplitInv(a,lower,center,upper,temp);
  int size = upper-lower+1;
  memcpy(a+lower,temp+lower,size*sizeof(int));

  return x+y+z;
}



int main(int argc,char *argv[])
{

  if (argc<2) {
    printf("Usage: %s input_file\n",argv[0]);
    return 1;
  }

  const char* filename = argv[1];
  FILE *ifp = fopen(filename,"r");

  int A[MAX];
  int n=0;
  while(!feof(ifp)) {
    fscanf(ifp,"%d", &A[n++]);
  }
  fclose(ifp);
  n--;
  
  printf("n=%d\n",n);
  // PrintArray(A,0,n-1);
  // n=100000;
  ll count=Sort_and_Count(A,0,n-1);
  printf("#inversions=%lld\n",count);
  // PrintArray(A,0,n-1);

  return 0;
}
