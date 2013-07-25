#include <iterator>
#include <iostream>
#include <fstream>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[]) {

  if (argc != 2)
    cout << "Usage: " << argv[0] << " filename" << '\n';

  ifstream input(argv[1]);
  copy(istreambuf_iterator<char>(input), istreambuf_iterator<char>(),
       ostreambuf_iterator<char>(cout));

  return 0;
}
