#include <iostream>
#include <sstream>

using namespace std;


string GetLine() {
  string result;
  getline(cin,result);
  return result;
}


int GetInteger() {
  // Read input until user enters valid data
  while(true) {
    stringstream converter;
    converter << GetLine();

    int result;
    if (converter >> result) {
      /* check that there isn't any leftover data ... */
      char remaining;
      if (converter >> remaining)  // something's left, input is invalid
	cout << "Unexpected character: " << remaining << endl;
      else
	return result;
    } else
      cout << "Please enter an integer." << endl;

    cout << "Retry: ";
  }
}

int main() {
  cout << "integer value = " << GetInteger() << endl;
  return 0;
}
