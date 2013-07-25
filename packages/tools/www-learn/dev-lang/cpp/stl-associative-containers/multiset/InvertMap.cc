#include <cstdio>
#include <map>
#include <utility>
#include <set>
#include <string>

using std::map;
using std::multiset;
using std::make_pair;
using std::pair;
using std::string;

int main() {
  map<string,int> myMap;

  myMap.insert(make_pair("STL",137));
  myMap.insert(make_pair("IS",42));
  myMap.insert(make_pair("AWESOME",2718));
  myMap.insert(make_pair("C++",137));
  myMap.insert(make_pair("IT",42));
  myMap.insert(make_pair("CS",42));

  multiset<pair<int,string> > myMulti;

  for (map<string,int>::iterator itr = myMap.begin(); itr != myMap.end(); ++itr)
    myMulti.insert(make_pair(itr->second,itr->first));

  for (multiset<pair<int,string> >::iterator itr = myMulti.begin();
       itr != myMulti.end();
       ++itr)
    printf("%d,%s\n",itr->first,itr->second.c_str());

  return 0;
}
