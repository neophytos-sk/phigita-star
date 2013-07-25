#include <cstdlib>   // srand,rand
#include <ctime>     // time
#include <algorithm> // copy, generate_n, random_shuffle
#include <fstream>   // ofstream
#include <iterator>  // inserter,istream_iterator,ostream_iterator
#include <set>
#include <vector>


using std::set;
using std::copy;
using std::ofstream;
using std::istream_iterator;
using std::ostream_iterator;
using std::generate_n;
using std::inserter;
using std::random_shuffle;
using std::vector;


#define MAX 10000000

int myrand() {
  return rand() % MAX;
}

int main() {
  srand(time(NULL));
  set<int> unique_values;
  vector<int> values;

  ofstream outfile;
  outfile.open("ten-million-integers.txt");
  generate_n(inserter(unique_values,unique_values.begin()),10000000,myrand);

  values.resize(unique_values.size());
  copy(unique_values.begin(),unique_values.end(),values.begin());
  random_shuffle(values.begin(),values.end());
  copy(values.begin(),values.end(),ostream_iterator<int>(outfile,"\n"));
  outfile.close();

  return 0;
}
