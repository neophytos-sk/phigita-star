#include <string>
#include <iostream>

template <typename FirstType, typename SecondType> struct MyPair
{
  FirstType first;
  SecondType second;
};

using namespace std;

int main()
{
  MyPair<int,string> thePair;
  thePair.first = 12;
  thePair.second = "neophytos";
  cout << "first=" << thePair.first << " second=" << thePair.second << endl;
  return 0;
}
