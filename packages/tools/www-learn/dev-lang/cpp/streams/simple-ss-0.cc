#include <sstream>
#include <iostream>

using namespace std;

int main() {
  stringstream myStream;
  myStream << "Hello!" << 137;

  cout << myStream.str() << endl;
  return 0;
}
