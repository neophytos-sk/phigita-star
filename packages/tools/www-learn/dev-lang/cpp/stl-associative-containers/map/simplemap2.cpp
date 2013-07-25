#include <map>
#include <iostream>
#include <string>

using namespace std;

int main()
{
  map<string,int> myMap;
  myMap["neophytos"] = 137;
  myMap["demetriou"] = 246;
  myMap.insert(make_pair("hello",11)); // avoid using insert for map. if key already exists , value is not replaced
  myMap["world"] = 888;

  map<string,int>::iterator itr;
  for(itr=myMap.begin(); itr!=myMap.end(); ++itr)
    cout << itr->first << " " << itr->second << endl;


  itr = myMap.lower_bound("google");
  if (itr != myMap.end()) 
    cout << "the first key that is greater than or equal to 'google' in myMap: " << itr->first << endl;

  return 0;
}
