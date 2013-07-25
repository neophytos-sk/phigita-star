#include <stdio.h>
#include <math.h>

void print_subset(int a[],int n,int bitmask) {
  int j;
  for(j=0;j<n;j++) {
    if (1<<j & bitmask) {
      printf("%d ",a[j]);
    }
  }
  printf("\n");
}

void print_all_subsets(int a[],int n) {
   int i=0;
   for(i=0;i<pow(2,n);i++) {
     print_subset(a,n,i);
   }
}

int main() {
  int a[]={1,2,3,4,5};
  print_all_subsets(a,5);
  return 0;
}
