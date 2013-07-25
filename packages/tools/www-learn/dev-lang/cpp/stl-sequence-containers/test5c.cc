#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <iterator>

const int kNumValues = 3;

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


size_t InsertionIndex(const vector<int>& v, int toInsert) {
  for (size_t i=0; i<v.size(); ++i)
    if (toInsert < v[i]) 
      return i;

  return v.size();
}

int main(){

  vector<int> values;
  for (int i=0; i<kNumValues, ++i) {
    int val = GetInteger();
    values.insert(values.begin() + InsertIndex(v,val), val);
  }
  SelectionSort(values);
  copy(values.begin(),values.end(),ostream_iterator<int>(cout,"\n"));
  return 0;
}
