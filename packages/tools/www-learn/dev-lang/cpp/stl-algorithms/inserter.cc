#include <cstdlib>    // rand, srand
#include <ctime>      // time
#include <algorithm>  // set_union, generate_n, copy
#include <iterator>   // inserter, ostream_iterator
#include <vector>
#include <iostream>   // cout

using std::vector;
using std::set_union;
using std::generate_n;
using std::inserter;
using std::copy;
using std::ostream_iterator;
using std::cout;
using std::sort;



int main() {

  srand(time(NULL));

  vector<int> setOne(10);
  vector<int> setTwo(20);
  vector<int> result;

  generate_n(setOne.begin(),10,rand);
  generate_n(setTwo.begin(),20,rand);
  set_union(setOne.begin(),setOne.end(),
	    setTwo.begin(),setTwo.end(),
	    inserter(result, result.begin()));

  //sort(result.begin(),result.end());
  copy(result.begin(),result.end(),ostream_iterator<int>(cout,"\n"));

  return 0;
}
