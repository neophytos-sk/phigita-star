#include <iostream>
#include <numeric>
#include <vector>

using namespace std;

typedef long long ll;

int equi ( const vector<int> &A ) {
  int n = A.size();
  ll right = accumulate(A.begin(),A.end(),(ll) 0);
  ll left=0;
  for(int i=0;i<n;i++) {
    right -= (ll) A[i];
    if (left==right) return i;
    left += (ll) A[i];
  }
  return -1;
}


int main() {

  vector<int> A;
  ll x;
  while(cin >> x)
    cout << x << endl, A.push_back(x);

  cout << equi(A) << endl;

  return 0;

}
