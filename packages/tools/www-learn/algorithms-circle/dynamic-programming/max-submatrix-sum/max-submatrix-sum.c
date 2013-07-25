#include <stdio.h>

#define INF &ffffffff

int maxSubArraySum(int a[], int size)
{
  int max_so_far = 0, max_ending_here = 0;
  int i;
  for(i = 0; i < size; i++)
    {
      max_ending_here = max_ending_here + a[i];
      if(max_ending_here < 0)
	max_ending_here = 0;
 
      /* Do not compare for all elements. Compare only
	 when  max_ending_here > 0 */
      else if (max_so_far < max_ending_here)
	max_so_far = max_ending_here;
    }
  return max_so_far;
}

#define MAX_N 10000

int maxSum(int array[MAX_N][MAX_N], int n) {
  int maxSum = -INF;
  int curSum[MAX_N];

  for(i = 0; i<n; i++)
    {
      for(j = 0; j<n; j++)
	curSum[j] = 0;

      for(k = i; k<n; k++)
	{
	  for(j = 0; j<n; j++)
	    curSum[j] = array[k][j];
 
	  newSum = MaxSumArray(curSum);
	  if(newSum > maxSum)
	    maxSum = newSum;
	}
    }

  return maxSum;
}


int main(int argc, char *argv[]) {
  maxSum(array,n);
  return 0;
}
