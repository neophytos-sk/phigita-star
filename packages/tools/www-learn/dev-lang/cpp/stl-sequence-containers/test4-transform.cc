#include <iterator>
#include <iostream>
#include <algorithm>
#include <sstream>
#include <vector>

using namespace std;

int op_increase(int i) { return ++i; }
int op_sum (int i, int j) { return i+j; }

int RandomNumber() { return rand()%1000; }

typedef long long ll;

int main(int argc, char *argv[]) {


  vector<int> myVector(10); // vector of 10 numbers
  vector<int> secondVector(10); // vector of 10 numbers

  cout << "=========== myVector" << '\n';

  generate(myVector.begin(), myVector.end(), RandomNumber);
  copy(myVector.begin(), myVector.end(), ostream_iterator<int>(cout,"\n"));

  cout << "=========== secondVector = myVector.+1" << '\n';

  transform(myVector.begin(), myVector.end(),secondVector.begin(), op_increase);
  copy(secondVector.begin(), secondVector.end(), ostream_iterator<int>(cout,"\n"));

  cout << "=========== sum of the two vectors" << '\n';

  transform(myVector.begin(), myVector.end(), secondVector.begin(), myVector.begin(), op_sum);
  copy(myVector.begin(), myVector.end(), ostream_iterator<int>(cout,"\n"));


  return 0;
}
