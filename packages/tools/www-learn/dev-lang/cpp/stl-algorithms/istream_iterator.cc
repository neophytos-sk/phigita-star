#include <algorithm>
#include <iterator>
#include <fstream>
#include <iostream>
#include <vector>

using std::copy;
using std::back_inserter;
using std::ifstream;
using std::vector;
using std::istream_iterator;
using std::ostream_iterator;
using std::cout;

int main() {
  ifstream infile;
  infile.open("data.txt");

  vector<int> values;
  copy(istream_iterator<int>(infile),istream_iterator<int>(),back_inserter(values));

  infile.close();


  copy(values.begin(),values.end(),ostream_iterator<int>(cout,"\n"));

  return 0;

}
