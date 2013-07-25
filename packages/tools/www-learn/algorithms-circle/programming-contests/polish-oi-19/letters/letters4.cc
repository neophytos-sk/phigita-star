#include <iostream>
#include <map>
#include <stack>
#include <cstring>

using namespace std;

typedef long long ll;

ll Merge_and_CountSplitInv(int a[],int lower, int center, int upper, int temp[])
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

ll Sort_and_Count(int a[], int lower, int upper, int temp[])
{

  if (upper == lower)
    return 0;

  int center = (lower + upper)/2;

  ll x = Sort_and_Count(a,lower,center,temp);
  ll y = Sort_and_Count(a,center+1,upper,temp);

  // merge the two sorted subarrays into temp
  ll z = Merge_and_CountSplitInv(a,lower,center,upper,temp);
  int size = upper-lower+1;
  memcpy(a+lower,temp+lower,size*sizeof(int));

  return x+y+z;
}




class Letters {
public:
  ll theMin(int n, const string& A, const string& B) {
    map<char,stack<int> > pos;

    int c[n+1];

    for(int i=0; i<n; i++)
      pos[A[i]].push(i);

    for (int i=n-1; i>=0; i--) {

      char letter = B[i];
      int p = pos[letter].top();
      pos[letter].pop();

      // target pos for element p is pos i
      c[p]=i;

    }

    int temp[n+1];
    return Sort_and_Count(c,0,n-1,temp);
  }
};

int main() {

  int n;

  cin >> n;


  string A;
  string B;

  cin >> A;
  cin >> B;

  Letters lit;
  cout << lit.theMin(n,A,B) << endl;

  return 0;

}
