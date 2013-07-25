/*

    count the number of elements in an array a which are absolute distinct, what it means is if an array had -3 and 3 in it these numbers are not distinct because|-3|=|3|. i think an example would clear it up better

a={-5,-3,0,1,3} the result would be 4 because there are 4 absolute distinct elements in this array.

The question also stated that a.length would be <=10000, and most importantly it stated that assume that the array is sorted in ascending order but i didnt really understand why we would need it to be sorted

*/

#include <iostream>
#include <vector>
#include <cmath>

using namespace std;

int absdistinct(const vector<int>& a) {

  int size=a.size();

  int left=0;
  int right=size-1;
  int count=0;
  while(left<right) {
    int lv = abs(a[left]);
    int rv = abs(a[right]);

    if (lv==rv)
      left++, right--;
    else if (lv > rv)
      left++;
    else
      right--;

    count++;
  }

  return count;

}


int main() {

  int x;
  vector<int> a;
  while(cin >> x)
    a.push_back(x);

  cout << "absdistinct=" << absdistinct(a) << endl;

  return 0;

}
