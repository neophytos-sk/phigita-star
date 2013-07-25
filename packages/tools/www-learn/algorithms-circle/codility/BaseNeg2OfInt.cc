#include <iostream>
#include <cmath>
#include <string>
#include <sstream>

using namespace std;

string itoa(int x) {
  stringstream converter;
  converter << x;
  string s;
  converter >> s;
  return s;
};

string Base2OfInt(int i) {

  int base = 2;
  string digits;
  while(i!=0) {
    int remainder = i%base;
    i = i/base;
    digits = itoa(remainder) + digits;
  }
  return digits;
}

string BaseNeg2OfInt(int i) {

  int base = -2;

  string digits;
  while (i != 0 ) {
    int remainder = i%base;
    i = i/base;
    if (remainder<0) {
      i += 1;
      remainder += abs(base);
    }
    digits = itoa(remainder) + digits;
  }
  return digits;
}



int main() {
  int x;
  cin >> x;
  // cout << base_repr(x,2) << endl;   // base=2, padding=0
  cout << Base2OfInt(x) << endl;
  cout << "-------------" << endl;
  cout << BaseNeg2OfInt(x) << endl;

  return 0;
}
