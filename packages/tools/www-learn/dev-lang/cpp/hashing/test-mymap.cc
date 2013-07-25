#include "MyMap.h"


int main() {
  MyMap<int> myMap;

  myMap.add("neophytos",123);
  myMap.add("demetriou",456);
  myMap.add("hello", 888);

  printf("myMap.getValue(\"neophytos\")=%d\n",myMap.getValue("neophytos"));
  printf("myMap.getValue(\"hello\")=%d\n",myMap.getValue("hello"));

  myMap.getValue("fcuk");
}
