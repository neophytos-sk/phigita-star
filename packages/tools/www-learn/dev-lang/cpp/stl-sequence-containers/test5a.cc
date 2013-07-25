#include <iostream>
#include <sstream>
#include <string>

using namespace std;

string GetLine() {
  string result;
  getline(cin,result);
  return result;
}

int GetInteger() {
  stringstream converter;
  int number;
  while(true) {
    //converter.clear();
    //converter.str("");
    converter << GetLine();

    if (converter >> number) {
      char remaining;
      if (converter >> remaining) { // something is left, input is invalid
	cout << "Unexpected character: " << remaining << '\n';
      } else {
	return number;
      }
    } else {
      cout << "Please enter an integer." << '\n';
    }
    cout << "Retry: ";
  }
}  

int main(){
  int val1=GetInteger();
  int val2=GetInteger();
  int val3=GetInteger();

  if (val2 <= val1 && val2 <= val3) {
    swap(val1,val2);
  } else if (val3 <= val1 && val3 <= val2) {
    swap(val1,val3);
  } // otherwise val1 is smallest, and can remain at the front

  if (val3 <= val2) {
    swap(val2,val3);
  } // otherwise, val2 is smaller than val3 and we don't need to do anything
  cout << val1 << ' ' << val2 << ' ' << val3 << endl;

  return 0;
}
