#include <cstdio>
#include <tr1/unordered_map>

using std::tr1::unordered_map; // hash map implementation of assoc container

int main() {
  unordered_map<char,int> myMap;

  myMap['a']=1;
  myMap['b']=2;
  myMap['c']=3;

  printf("%d\n",myMap['b']);

  return 0;
}
