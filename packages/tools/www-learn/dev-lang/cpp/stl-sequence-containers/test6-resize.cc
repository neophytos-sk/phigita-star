#include <iostream>
#include <vector>

using namespace std;

void PrintVector(const vector<int>& elems) {
  for(size_t i=0; i< elems.size(); ++i) {
    cout << elems[i] << ' ';
  }
  cout << '\n';
}

int main(){

  vector<int> myVector;  // Defaults to empty vector
  PrintVector(myVector); // Output: [nothing]
  
  myVector.resize(10);   // Grow the vector, setting new elements to 0
  PrintVector(myVector); // Output: 0 0 0 0 0 0 0 0 0 0
  
  myVector.resize(5);    // Shrink the vector
  PrintVector(myVector); // Output: 0 0 0 0 0
  
  myVector.resize(7,1);  // Grow the vector, setting new elements to 1 
  PrintVector(myVector); // Output: 0 0 0 0 0 1 1
  
  myVector.resize(1,7);  // The second parameter is effectively ignored.
  PrintVector(myVector); // Output: 0
}
