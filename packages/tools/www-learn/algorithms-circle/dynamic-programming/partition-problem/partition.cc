/* The Partition Problem
 * Suppose a given arrangement of S of non-negative numbers {a_1,...,a_n} and
 * an integer k. How to cut S into k or fewer ranges, so as to minimize the
 * maximum sum over all the ranges?
 *
 * Dynamic Programming Solution: Let OPT[n][k] be the minimum possible cost
 * over all partitionings of {a_1,...,a_n} into k ranges, where the cost of 
 * a partition is the largest sum of elements in one of its parts.
 *
 * OPT[n][k] = min_{1<=i<=n-1} { max(OPT[i][k-1],Sum_{i+1<=j<=n} a_j) }
 * OPT[i][1] = Sum_{1<=i<=n} a_i
 * OPT[1][i] = a_1 for all k>0
 *
 * Time Complexity is O(kn^3)
 *
 * Based on notes by Shihui Xue
 *
 */

#include <iostream>
#include <limits>

#define INF (std::numeric_limits<int>::max())
#define MAX_N 1000
#define MAX_K 1000

int max(int x, int y) { return x>y?x:y; }

void solve_partition(int a[], int n, int k, int OPT[MAX_N][MAX_K], int D[MAX_N][MAX_K]) {

  int p[n];
  int i,j,x;
  for(i=1;i<=n;i++) p[i]=p[i-1]+a[i];  /* p[x] = compute_sum(a,i,x) */
  for(i=1;i<=n;i++) OPT[i][1] = p[i];  /* boundary conditions */
  for(i=1;i<=k;i++) OPT[1][i] = a[1];

  for(i=2;i<=n;i++) {  /* evaluate main recurrence */
    for(j=2;j<=k;j++) {
      OPT[i][j] = INF;
      for(x=1;x<=i-1;x++) { /* try all divider positions up to i elements and up to j cuts  */ 
	int s = max(OPT[x][j-1],p[i]-p[x]);  /* p[i]-p[x] = compute_sum(a,x,i); */
	if(OPT[i][j] > s) {
	  OPT[i][j]=s;
	  D[i][j]=x; /* divider position */
	}
      }
    }
  }
}

void print_partition(int a[],int start,int end) {
  int i;
  for(i=start;i<=end;i++)
    std::cout << " " << a[i];
  std::cout << '\n';
}

void reconstruct_partition(int a[], int D[MAX_N][MAX_K], int n, int k) {
  if (k==1) {
    print_partition(a,1,n);
  } else {
    reconstruct_partition(a,D,D[n][k],k-1);
    print_partition(a,1+D[n][k],n);
  }
}

int main() {

  // inpu data
  int a[] = {0,10,4,2,7};  // first element is dummy
  int n = 4;
  int k = 2;
 
  int OPT[MAX_N][MAX_K];
  int D[MAX_N][MAX_K];
  
  solve_partition(a,n,k,OPT,D);

  // best segmentation is (10) (4,2,7)
  std::cout << "minmax=" << OPT[n][k] << '\n';
  reconstruct_partition(a,D,n,k);

  return 0;
}
