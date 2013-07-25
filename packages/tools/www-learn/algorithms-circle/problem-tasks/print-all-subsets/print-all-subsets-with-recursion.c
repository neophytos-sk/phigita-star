#include <stdio.h>
#include <math.h>

void print_subset(int a[],int n,int bitmask[]) {
  int j;
  for(j=0;j<n;j++) {
    if (bitmask[j]) {
      printf("%d ",a[j]);
    }
  }
  printf("\n");
}

void print_all_subsets_(int a[],int n,int current, int bitmask[]) {
  if (n==current) {
    print_subset(a,n,bitmask);
    return;
  }
  bitmask[current]=1;
  print_all_subsets_(a,n,current+1,bitmask);
  bitmask[current]=0;
  print_all_subsets_(a,n,current+1,bitmask);
}

void print_all_subsets(int a[],int n) {
  int bitmask[] = {0};
  print_all_subsets_(a,n,0,bitmask);
}

int main() {
  int a[]={1,2,3,4,5};
  print_all_subsets(a,5);
  return 0;
}
