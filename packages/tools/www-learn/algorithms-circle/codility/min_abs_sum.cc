/*
Given an array A of n integers, and the sequence S of n elements 1 or -1 we define the value:

val(A,S) = abs(\sum_{i=0}^{n-1}A[i]S[i])

Assume the sum of zero elements is equal zero. Write a function

int min_abs_sum(int[] A);

than given an array A of n integers from the range [-100..100] computes the lowest possible value of val(A,S) (for any sequence S with elements 1 or -1). You can assume that n<=20000 .

For example given array: a={1,5,2,-2}

your function should return 0, since for sequence S=(-1,1,-1,1) the val(A,S)=0.

*/

#include <iostream>
#include <numeric>
#include <vector>
#include <iomanip>

#define RA(x) (x).begin(),(x).end()

using namespace std;


int min_abs_sum(const vector<int> a) {

  int n = a.size();
  int sum = accumulate(RA(a),0);

  bool p[sum+1][n+1];

  int s[sum/2+1][n+1];
  for(int i=0;i<=sum/2;i++)
    for(int j=0;j<=n;j++)
      s[i][j] = 0,p[i][j]=false;

  for(int j=0; j<=n; j++)
    p[0][j] = true;

  for(int i=1; i<=sum/2; i++) {
    for(int j=1; j<=n; j++) {
      int index = j-1;
      int value = a[index];

      p[i][j] = p[i][j-1] || (value>i?false:p[i-value][j-1]);

      if (p[i][j])
	if (p[i][j-1])
	  s[i][j] = s[i][j-1];
	else
	  s[i][j] = index;

    }
  }

  /*
  for(int i=0;i<=sum/2;i++) {
    cout << "sum=" << i;
    for(int j=1;j<=n;j++) {
      cout << setw(2) << s[i][j] << " ";
    }
    cout << endl;
  }
  */


  
  int target=sum/2;
  while(target>0) {
    int value = a[s[target][n]];
    cout << value << endl;
    target -= value;
  }
    

  return p[sum/2][n];

}

int main() {

  vector<int> a;
  int x;
  while(cin >>x) a.push_back(x);

  cout << "min_abs_sum=" << min_abs_sum(a) << endl;

  return 0;

}
