#include <utility> // for pair
#include <iostream>
#include <string>

using namespace std;

int main()
{
  pair<int,string> myPair = make_pair(137,"C++ is awesome!");

  cout << "first="<< myPair.first << " second=" << myPair.second << endl;
  return 0;
}
