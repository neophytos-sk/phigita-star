#include <cstdlib>
#include <ctime>
#include <algorithm>  // for generate, copy
#include <iterator>   // for ostream_iterator
#include <vector>
#include <iostream>   // for cout

using std::generate;
using std::vector;
using std::ostream_iterator;
using std::cout;
using std::sort;

int main(int argc, char *argv[]) {

  vector<int> values(10);

  srand(time(NULL));
  //values.resize(10);
  generate(values.begin(),values.end(),rand);
  //generate_n(values.begin(),10,rand);
  sort(values.begin(),values.end());
  copy(values.begin(),values.end(),ostream_iterator<int>(cout,"\n"));

  return 0;
}
