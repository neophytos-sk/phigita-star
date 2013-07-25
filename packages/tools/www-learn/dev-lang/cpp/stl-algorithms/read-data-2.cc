#include <iostream>
#include <fstream>  // for ifstream
#include <set>      // for multiset
#include <numeric>  // for accumulate
#include <iterator> // for istream_iterator
#include <algorithm> // for copy

using std::multiset;
using std::ifstream;
using std::cout;
using std::endl;
using std::accumulate;
using std::istream_iterator;
using std::copy;
using std::inserter;

int main()
{
  ifstream input("data.txt");
  multiset<int> values;

  /* Read the data from the file. */
  int currValue;
  //while (input >> currValue) values.insert(currValue);
  copy(istream_iterator<int>(input),istream_iterator<int>(),inserter(values,values.begin()));

  /* Compute the average. */
  double total = 0.0;

  cout << "Average is: " 
       <<   accumulate(values.begin(),values.end(),0.0) / values.size() 
       << endl;

  /* if we want to compute the sum of the elements of the multiset that are
   * between 42 and 137, inclusive, we could write:
   * accumulate(values.lower_bound(42), values.upper_bound(137),0);
   */
}
