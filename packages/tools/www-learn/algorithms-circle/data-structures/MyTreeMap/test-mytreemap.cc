#include <iostream>

#include "mytreemap.h"

using std::cout;

int main() {
  MyTreeMap<int> myMap;

  myMap.add("neophytos",123);
  myMap.add("demetriou",456);
  myMap.add("hello",888);

  cout << myMap.getValue("neophytos") << '\n';
  cout << myMap.getValue("demetriou") << '\n';
  cout << myMap.getValue("hello") << '\n';
}
