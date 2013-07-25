// create a list of random numbers, sort it, and print it to the console


#include <iostream>
#include <iterator>
#include <vector>
#include <algorithm>

using namespace std;

#define vi vector<int>

#define NUM_INTS 10


int main() {

  vector<int> myVector(NUM_INTS);
  generate(myVector.begin(), myVector.end(), rand);
  sort(myVector.begin(), myVector.end());
  copy(myVector.begin(), myVector.end(), ostream_iterator<int>(cout,"\n"));

  return 0;
}
