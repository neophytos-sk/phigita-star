#include <map>
#include <iostream>
#include <string>

using namespace std;

int main()
{
  map<string,int> myMap;
  myMap["neophytos"] = 137;
  myMap["demetriou"] = 246;
  myMap["hello"] = 11;
  myMap["world"] = 888;
  if (myMap.find("world") != myMap.end())
    cout << "found" << endl;
  else
    cout << "not found" << endl;


  return 0;
}
