#include <cstdlib>   // srand,rand
#include <ctime>     // time
#include <algorithm> // copy
#include <fstream>   // ofstream
#include <iterator>  // ofstream_iterator
#include <vector>


using std::vector;
using std::copy;
using std::ofstream;
using std::ostream_iterator;

#define MAX 10000000

int myrand() {
  return rand() % MAX;
}

int main() {
  srand(time(NULL));
  vector<int> values(10000000);

  ofstream outfile;
  outfile.open("ten-million-integers.txt");
  generate(values.begin(),values.end(),myrand);
  copy(values.begin(),values.end(),ostream_iterator<int>(outfile,"\n"));
  outfile.close();

  return 0;
}
