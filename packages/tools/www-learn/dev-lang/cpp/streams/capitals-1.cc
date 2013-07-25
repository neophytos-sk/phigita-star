#include <fstream>
#include <iostream>

using namespace std;

int main() {
  ifstream capitals("world-capitals.txt");
  if (!capitals.is_open()) {
    cerr << "Cannot find the file world-capitals.txt" << endl;
    return -1;
  }


  string city, country;
  while(getline(capitals,city) && getline(capitals,country)) {
    cout << city << " is the capital of " << country << endl;
  }

  return 0;
}
