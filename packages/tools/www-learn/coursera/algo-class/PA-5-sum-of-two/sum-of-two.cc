#include <unordered_set>
#include <fstream>
#include <iostream>

using namespace std;

bool sum_of_two(const unordered_set<int>& h, int sum) {
  for(unordered_set<int>::const_iterator it = h.begin(); it != h.end(); ++it)
    if (h.count(sum-(*it)))
      return true;

  return false;
}

void read_data(const char *filename, unordered_set<int>& h) {
  ifstream infile;
  infile.open(filename);
  int x;
  while (infile >> x)
    h.insert(x);
  infile.close();
      
}

int main(int argc, char *argv[]) {

  if (argc != 2) {
    cout << "Usage: " << argv[0] << " filename\n";
    return 1;
  }

  int target_sum[9] = {231552,234756,596873,648219,726312,981237,988331,1277361,1283379};

  unordered_set<int> h;
  read_data(argv[1],h);

  for(int i=0;i<9;i++)
    cout << sum_of_two(h,target_sum[i]);

  cout << endl;

  return 0;
}
