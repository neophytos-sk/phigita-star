/*


    A non-empty zero-indexed array A consisting of N integers is given. The first covering prefix of array A is the smallest integer P such that 0 ≤ P < N and such that every value that occurs in array A also occurs in sequence A[0], A[1], ..., A[P].

For example, the first covering prefix of the following 5−element array A:

A[0] = 2  A[1] = 2  A[2] = 1
A[3] = 0  A[4] = 1

is 3, because sequence [ A[0], A[1], A[2], A[3] ] equal to [2, 2, 1, 0], contains all values that occur in array A.

*/

#include <iostream>
#include <set>
#include <vector>

using namespace std;

int coveringprefix(const vector<int> a) {

  set<int> s;

  int size = a.size();

  int p=0;
  for(int i=0; i< size; i++)
    if (!s.count(a[i]))
      s.insert(a[i]),p=i;

  return p;

}

int main() {

  vector<int> a;
  int x;
  while (cin >> x) 
    a.push_back(x);

  cout << "coveringprefix=" << coveringprefix(a) << endl;

  return 0;

}
