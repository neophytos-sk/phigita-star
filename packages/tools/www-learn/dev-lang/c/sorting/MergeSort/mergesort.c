#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 1000


void PrintArray(const int A[],int from, int to)
{
  int i;
  for(i=from;i<=to;++i)
    printf("%d ",A[i]);
  printf("\n");
}

void merge(int a[],int lower, int center, int upper, int temp[])
{
  int i=lower,j=center+1, k=lower;

  // merge the two sorted subarrays to temp
  while(i<=center && j<=upper) {
    if (a[i] <= a[j]) {
      temp[k] = a[i];
      i++;
    } else {
      temp[k] = a[j];
      j++;
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


}

void MergeSort(int a[], int lower, int upper)
{

  if (upper == lower)
    return;


  int temp[MAX];

  int center = (lower + upper)/2;
  MergeSort(a,lower,center);
  MergeSort(a,center+1,upper);

  // merge the two sorted subarrays into temp
  merge(a,lower,center,upper,temp);
  int size = upper-lower+1;
  memcpy(a+lower,temp+lower,size*sizeof(int));

}



int main(int argc,char *argv[])
{
  int A[MAX];
  int n = argc - 1;
  int i;

  for(i=1;i<argc;++i)
    A[i-1] = atoi(argv[i]);

  PrintArray(A,0,n-1);
  MergeSort(A,0,n-1);
  PrintArray(A,0,n-1);

  return 0;
}
