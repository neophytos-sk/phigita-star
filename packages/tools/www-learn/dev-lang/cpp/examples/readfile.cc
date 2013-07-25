#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[]) {

  if (argc!=2) {
     cout << "Usage: " << argv[0] << " filename" << endl;
     return 0;
  }

  const char *filename = argv[1];
  cout << "opening file " << filename << endl;

  ifstream in(filename);

  while (!in.eof()) {
    int value;
    if (!(in >> value)) break;
    cout << value << endl;
  }
  return 0;
}
