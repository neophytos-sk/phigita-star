#include <stdio.h>
#include <stdlib.h>

void swap(int *x, int *y)
{
  const int temp = *x;
  *x=*y;
  *y=temp;
}

void PrintArray(int a[], int from, int to)
{
  int i;
  for(i=from;i<=to;++i)
    printf("%d ",a[i]);
  printf("\n");
}


int partition(int *a, int size) {
  int Left = 0;
  int Right = size-1;
  int pivot = a[0];

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
  PrintArray(a,0,size-1);
  return Middle;

}

int select_kth_smallest_element(int *a, int size, int k){

  printf("trying to find rank=%d out of size=%d\n",k,size);

  int left = 0;
  int right = size-1;

  int middle = partition(a,size);
  printf("middle=%d k=%d size-middle=%d\n",middle,k,size-middle);
  

  if (middle > k)
    select_kth_smallest_element(a,middle,k);
  else if (middle < k)
    select_kth_smallest_element(a+middle+1,size-(middle+1),k-(middle+1));
  else
    return a[middle];
}

int selection(int *values, int size, int k) {

  if (size < 1) {
    fprintf(stderr,"size=%d\n",size);
    exit(-1);
  }

  if (k<0 || k>=size) {
    fprintf(stderr,"out of bounds: k=%d must be less than size=%d\n",k,size);
    exit(-1);
  }
  return select_kth_smallest_element(values,size,k-1);  // make sure we are counting from the same base, i.e. zero
}



int main(int argc, char *argv[])
{
  if (argc < 3) {
    fprintf(stderr,"Usage: %s k num1 ... numN\n",argv[0]);
    return 1;
  }

  int n = argc - 2;
  int *a = (int *) malloc(n * sizeof(int));
  int i;
  for(i=2;i<argc;++i)
    a[i-2]=atoi(argv[i]);

  int k = atoi(argv[1]);
  int result = selection(a,n,k);
  printf("the kth (=%d) smallest element is: %d\n",k,result);


  return 0;
}

