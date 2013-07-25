#include <cstdio>
#include <set>
#include <sstream>
#include <string>

#include "set_utils.h"

using std::set;
using std::string;
using std::stringstream;

int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr,"Usage: %s <set1> <set2>\n",argv[0]);
    return 1;
  }

  set<int> set1;
  set<int> set2;

  string str1 = argv[1];
  string str2 = argv[2];
  stringstream ss1(str1);
  stringstream ss2(str2);

  int value;
  while(ss1 >> value)
    set1.insert(value);

  while(ss2 >> value)
    set2.insert(value);
  
  set<int> myUnion;
  set_union(set1,set2,myUnion);
  PrintSet(myUnion);


  return 0;
}
