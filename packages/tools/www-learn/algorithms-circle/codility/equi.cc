// find an index in an array that its prefix sum is equal to its suffix sum.

#include <iostream>
#include <vector>
#include <numeric>


#define RA(x) (x).begin(),(x).end()
#define SZ(x) (x).size()

using namespace std;

int equi(const vector<int>& a) {
  long long right = accumulate(RA(a),0);
  long long left = 0;
  int prev=0;
  int size=SZ(a);
  cout << "size=" << size << endl;

  for(int i=0;i<size;i++) {
    prev = a[i];
    left += prev;
    right -= a[i];

    cout << "left=" << left << " right=" << right << endl;

    if (left==right)
      return i;
  }
  return -1;
}

int main() {

  vector<int> xs;
  int x;
  while(cin >> x)
    xs.push_back(x);

  cout << "equi=" << equi(xs);

  return 0;
}
