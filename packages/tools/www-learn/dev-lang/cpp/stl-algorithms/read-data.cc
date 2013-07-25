#include <iostream>
#include <fstream>  // for ifstream
#include <set>      // for multiset

using std::multiset;
using std::ifstream;
using std::cout;
using std::endl;

int main()
{
  ifstream input("data.txt");
  multiset<int> values;

  /* Read the data from the file. */
  int currValue;
  while (input >> currValue)
    values.insert(currValue);

  /* Compute the average. */
  double total = 0.0;
  for (multiset<int>::iterator itr = values.begin();
       itr != values.end(); ++itr)
    total += *itr;
  cout << "Average is: " << total / values.size() << endl;
}
