#include <bitset>
#include <fstream>

using std::ifstream;
using std::ofstream;
using std::bitset;


int main() {
  bitset<10000000> bit;

  ifstream infile;
  infile.open("ten-million-integers.txt");

  for (int i=0; i<10000000; ++i)
    bit[i]=0;

  int x;
  while (infile >> x) 
    bit[x] = 1;

  infile.close();

  ofstream outfile;
  outfile.open("sorted-ten-million-integers.txt");
  for (int i=0; i<10000000; ++i) 
    if (bit[i])
      outfile << i << '\n';
  outfile.close();

  return 0;

}
