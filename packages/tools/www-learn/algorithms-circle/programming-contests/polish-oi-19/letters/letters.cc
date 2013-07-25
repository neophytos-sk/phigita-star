#include <iostream>

#define COST(a,b) ((b)-(a))

using namespace std;


void shift(char A[], int a, int b) {
  for(int i=a; i<b; i++)
    A[i]=A[i+1];
}

int solve(int n, char A[], char B[]) {

  if (n==0) {
    return 0;
  } else {
    for(int p=n; p>0; p--) {
      if (A[p]==B[n]) {
	shift(A,p,n);  // shift A[p] to A[j]
	return COST(p,n) + solve(n-1,A,B);
      }
    }
  }
}

int main() {

  int n;

  cin >> n;


  char A[n+1];  // Johny's surname
  char B[n+1];  // Mary's surname

  for(int i=0; i<n; i++)
    cin >> A[i+1];

  for(int i=0; i<n; i++)
    cin >> B[i+1];

  // cout << "min num of adj swaps = " << solve(n,A,B) << endl;

  cout << solve(n,A,B) << endl;

  return 0;

}
