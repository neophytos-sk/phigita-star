#include <iostream>
#include <cstring>

using namespace std;

typedef long long ll;

ll Merge_and_CountSplitInv(char a[],int lower, int center, int upper, char temp[])
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

ll Sort_and_Count(char a[], int lower, int upper, char temp[])
{

  if (upper == lower)
    return 0;

  int center = (lower + upper)/2;

  ll x = Sort_and_Count(a,lower,center,temp);
  ll y = Sort_and_Count(a,center+1,upper,temp);

  // merge the two sorted subarrays into temp
  ll z = Merge_and_CountSplitInv(a,lower,center,upper,temp);
  int size = upper-lower+1;
  memcpy(a+lower,temp+lower,size*sizeof(char));

  return x+y+z;
}



int main(int argc,char *argv[])
{

  int n;
  cin >> n;
  char A[n+1];
  char temp[n+1];

  for(int i=0;i<n;i++)
    cin >> A[i];

  // printf("n=%d\n",n);
  ll count=Sort_and_Count(A,0,n-1,temp);
  cout << "#inversions=" << count << endl;

  for(int i=0;i<n;i++)
    cin >> A[i];

  count=Sort_and_Count(A,0,n-1,temp);
  cout << "#inversions=" << count << endl;

  return 0;
}
