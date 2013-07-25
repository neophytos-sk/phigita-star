#include <iostream>
#include <map>
#include <stack>
#include <set>

#define COST(a,b) ((b)-(a))

using namespace std;

int solve(int n, char A[], char B[]) {

  map<char,stack<int> > pos;
  multiset<int> sofar;

  for(int i=1; i<=n; i++)
    pos[A[i]].push(i);

  int total=0;
  for (int i=n; i>0; i--) {
    int p = pos[B[i]].top();
    pos[B[i]].pop();

    int cost = COST(p,i);

    // shift(A,p,n);
    multiset<int>::const_iterator it = sofar.begin();
    multiset<int>::const_iterator stop = sofar.lower_bound(p);
    for(;it!=stop; ++it)
	cost++;

    total += cost;
    sofar.insert(p);
  }
  return total;
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
