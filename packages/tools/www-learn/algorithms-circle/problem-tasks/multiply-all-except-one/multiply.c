// You are given an array [a1 to an] and we have to construct another 
// array [b1 to bn] where bi=a1*a2*...*an/ai. you are allowed to use only 
// constact space and the time complexity is O(n). No divisions are allowed.
#include <stdio.h>

#define N 5

void multiply_except(int a[], int b[], int n) {
  int i, result;

  for(i=0; i<n; ++i)
    b[i]=1;

  result = 1;
  for(i=0;i<n;++i)
    b[i] *= result, result *= a[i];

  result = 1;
  for(i=n-1;i>=0;--i)
    b[i] *= result, result *= a[i];

}

// kind of complicated check simpler solution above
void multiply_except_2(int a[], int b[], int n) {

  int i,l[n], r[n];
  
  for (i=0;i<n;++i)
    l[i]=1,r[i]=1;

  for (i=1;i<n;++i) {
    l[i] *= l[i-1]*a[i-1];
    r[n-i-1] *= r[n-i]*a[n-i];
  }

  for (i=0;i<n;++i)
    b[i] = l[i]*r[i];

}

void print_array(int x[], int n) {
  int i;
  for(i=0;i<N;++i) {
    printf("%d\n",x[i]);
  }
}

int main() {
  int a[N] = {4,2,8,3,7};
  int b[N];

  printf("\nmultiply_except\n");
  multiply_except(a,b,N);
  print_array(b,N);
  printf("\nmultiply_except_2\n");
  multiply_except_2(a,b,N);
  print_array(b,N);

  return 0;
}
