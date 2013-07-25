#include <algorithm> // for reverse_copy, generate_n, sort, copy
#include <vector>    // for vector
#include <iostream>  // for cout
#include <iterator>  // for back_inserter
#include <cstdlib>   // for srand, rand
#include <ctime>     // for time
#include <iterator>  // for ostream_iterator

using std::generate;
using std::back_inserter;
using std::vector;
using std::reverse_copy;
using std::ostream_iterator;
using std::cout;
using std::sort;

int main() {

  srand(time(NULL));

  vector<int> values(10);
  vector<int> newValues;
  generate_n(values.begin(),10,rand);
  sort(values.begin(),values.end());
  reverse_copy(values.begin(),values.end(),back_inserter(newValues));

  copy(newValues.begin(), newValues.end(), ostream_iterator<int>(cout,"\n"));

  return 0;

}
