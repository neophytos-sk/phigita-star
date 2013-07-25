#include <iostream>
#include <sstream>

#include "simpio.h"

/* Accepts an int and returns whether or not that integer's 
 * hexadecimal representation contains letters.
 */
bool HasHexLetters(int intValue) {
  stringstream buffer;
  buffer << hex << intValue;

  int x;
  buffer >> dec >> x;
  if (buffer.fail()) return true;

  char ch;
  buffer >> ch;
  if (!buffer.fail()) return true;

  return false;
}

int main() {
  int intValue;
  intValue = GetInteger();
  cout << "Hexadecimal representation = " << hex << intValue << dec << '\n';
  cout << "HasHexLetters(" << intValue <<") = ";
  cout << boolalpha << HasHexLetters(intValue) << noboolalpha << '\n';
  return 0;
}
