#include <iostream>
#include <vector>
#include <cstring>  // for memset

using namespace std;

template <class T> inline void checkmin(T& a, T b) { if (a>b) { a=b; } }

int deepest_pit ( const vector<int> &A ) {

  int n = A.size();
  int depth[n+1];
  memset(depth,0,sizeof(depth));


  int p=0;
  for(int i=1;i<n;i++)
    if (A[i-1]<=A[i]) {
      depth[i-1]= A[p]-A[i-1];  // q=i-1
      p=i;
    }

  int r=n-1;
  for(int i=n-1;i>=0;i--) {
    if (A[i]>=A[i+1]) {
      checkmin(depth[i+1],A[r]-A[i+1]);  // q=i+1
      r=i;
     }
  }

  int best=0;
  for(int i=0;i<n;i++) {
    if (best<depth[i])
      best=depth[i];
  }

  return best;
}


     // cout << "r=" << r << " depth[i+1]=" << depth[i+1] << " A[r]=" << A[r] << " A[i+1]=" << A[i+1] << endl;

int main() {
  int x;
  vector<int> A;
  while(cin >> x)
    A.push_back(x);

  cout << "deepest pit=" << deepest_pit(A) << endl;

  return 0;

}
