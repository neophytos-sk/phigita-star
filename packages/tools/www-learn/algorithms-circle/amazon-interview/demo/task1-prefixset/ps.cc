#include <iostream>
#include <vector>
#include <cstring>  // for memset

using namespace std;

int ps(const vector<int>& A) {

  int n = A.size();
  int p[n];
  memset(p,-1,sizeof(p));

  int covering_prefix = n;
  for(int i=0;i<n;i++)
    if (p[A[i]] == -1) {
      p[A[i]]=i;
      covering_prefix=i;
    }

  return covering_prefix;
}


int main() {

  vector<int> A;
  int x;
  while(cin >> x)
    A.push_back(x);

  cout << "covering prefix=" << ps(A) << endl;

  return 0;

}
