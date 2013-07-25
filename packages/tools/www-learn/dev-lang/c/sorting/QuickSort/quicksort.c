#include <stdio.h>
#include <stdlib.h>


void swap(int *x, int *y)
{
  const int temp = *x;
  *x=*y;
  *y=temp;
}


int selectPivotIndex(const int a[],int size)
{
  // select the 1st element of the array as the pivot
  return 0;
}

int partition(int *a,int size)
{

  int pivot = a[0];
  int Left = 0;
  int Right = size-1;

  int L = Left;
  int R = Right;
  while (L<R) {
    while (a[L]<=pivot && L<=Right) ++L;
    while (a[R]>pivot && R>=Left) --R;
    if (L<R)
      swap(&a[L],&a[R]);
  }
  int Middle = R;
  swap(&a[Left],&a[Middle]);
  printf("pivot=%d\n",pivot);
  PrintArray(a,Left,Right);
  return Middle;
}

void QuickSort(int *a, int size)
{

  if (size<=1)
    return;

  int pivotIndex = selectPivotIndex(a,size);
  swap(&a[0],&a[pivotIndex]);
  int Middle=partition(a,size);
  QuickSort(a,Middle);
  QuickSort(a+Middle+1,size-Middle-1);

}


void PrintArray(int a[], int from, int to)
{
  int i;
  for(i=from;i<=to;++i)
    printf("%d ",a[i]);
  printf("\n");
}

int main(int argc, char *argv[])
{
  int n = argc - 1;
  int *a = (int *) malloc(argc * sizeof(int));
  int i;
  for(i=1;i<argc;++i)
    a[i-1]=atoi(argv[i]);
  QuickSort(a,n);
  
  PrintArray(a,0,n-1);

  return 0;
}
