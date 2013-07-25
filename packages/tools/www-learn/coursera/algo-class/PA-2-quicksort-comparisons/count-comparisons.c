#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// #define MACRO_selectPivotIndex selectPivotIndex_first
// #define MACRO_selectPivotIndex selectPivotIndex_final
#define MACRO_selectPivotIndex selectPivotIndex_median_of_three

#define MAXLEN 110000

#define max(a,b) (a)>=(b)?(a):(b)
#define min(a,b) (a)<=(b)?(a):(b)

typedef long long ll;

ll count = 0;

void PrintArray(const int A[],int from, int to)
{
  int i;
  for(i=from;i<=to;++i)
    printf("%d ",A[i]);
  printf("\n");
}


void swap(int *x, int *y)
{
  const int temp = *x;
  *x=*y;
  *y=temp;
}

int median(int a, int b, int c) {

  int smallest = min(min(a,b),c);

  if (smallest==a)
    return min(b,c);
  else if (smallest==b)
    return min(a,c);
  else if (smallest==c)
    return min(a,b);


}

int selectPivotIndex_first(const int a[],int size) {
  // select the 1st element of the array as the pivot
  return 0;
}

int selectPivotIndex_final(const int a[],int size) {
  // select the final element of the array as the pivot
  return size-1;
}

int selectPivotIndex_median_of_three(const int a[],int size) {

  int first = a[0];
  int final = a[size-1];
  int middle_index;
  if (size % 2 == 0) 
    middle_index = size/2 - 1;
  else
    middle_index = (size+1)/2 -1;
  
  int middle = a[middle_index];

  int the_median = median(first,middle,final);

  if (the_median==first) 
    return 0;
  else if (the_median==middle)
    return middle_index;
  else 
    return size-1;

}

int partition(int *a,int size)
{

  int pivot = a[0];
  int Left = 0;
  int Right = size-1;

  int L = Left+1;
  int R = Right;
  int i=Left+1,j;
  for(j=L;j<=R;j++) {
    if (a[j]<pivot) {
      swap(&a[j],&a[i]);
      i=i+1;
    }
  }

  if (Left != i-1) 
    swap(&a[Left],&a[i-1]);

  // printf("pivot=%d\n",pivot);
  // PrintArray(a,Left,Right);

  return i-1;
}

void QuickSort(int *a, int size)
{

  if (size<=1)
    return;

  count += size-1;

  int pivotIndex = MACRO_selectPivotIndex(a,size);
  swap(&a[0],&a[pivotIndex]);
  int Middle=partition(a,size);
  QuickSort(a,Middle);
  QuickSort(a+Middle+1,size-Middle-1);

}



int main(int argc,char *argv[])
{

  //printf("median of 1,2,3 = %d\n",median(1,2,3));

  if (argc<2) {
    printf("Usage: %s input_file\n",argv[0]);
    return 1;
  }

  const char* filename = argv[1];
  FILE *ifp = fopen(filename,"r");

  int A[MAXLEN];
  int n=0;
  while(!feof(ifp)) {
    fscanf(ifp,"%d", &A[n++]);
  }
  fclose(ifp);
  n--;
  
  printf("n=%d\n",n);
  // PrintArray(A,0,n-1);
  // n=100000;
  QuickSort(A,n);
  printf("#comparisons= %lld\n",count);
  //PrintArray(A,0,n-1);

  return 0;
}
