#include <utility> // for pair
#include <iostream>
#include <string>

using namespace std;

int main()
{
  pair<int,string> myPair;
  myPair.first = 5;
  myPair.second = "neophytos";
  cout << "first="<< myPair.first << " second=" << myPair.second << endl;
  return 0;
}
