#include <iostream>
#include <map>
#include <stack>

#define COST(a,b) ((b)-(a))

using namespace std;

int solve(int n, char A[], char B[]) {

  map<char,stack<int> > pos;

  int c[n];

  for(int i=0; i<n; i++) {
    pos[A[i]].push(i);
    c[i]=0;
  }

  int total=0;
  for (int i=n-1; i>=0; i--) {

    char letter = B[i];
    int p = pos[letter].top();
    pos[letter].pop();

    total += COST(p-c[p],i);

    for (int j=p;j<n;j++)
      c[j]++;

  }
  return total;
}

int main() {

  int n;

  cin >> n;


  char A[n];  // Johny's surname
  char B[n];  // Mary's surname

  cin >> A;
  cin >> B;

  // cout << "min num of adj swaps = " << solve(n,A,B) << endl;

  cout << solve(n,A,B) << endl;

  return 0;

}
