/* STL Function Objects, see book by Josuttis */

#include <cstdio>
#include <algorithm>
#include <list>

using std::list;
using std::generate_n;
using std::back_inserter;

class IntSequence {
public:
  IntSequence(int initial_value = 0) : value(initial_value) {}
  int operator()() { return value++; }
private:
  int value;
};


void print_elements(const list<int>& coll) {
  for(list<int>::const_iterator itr = coll.begin();
      itr != coll.end();
      ++itr) {
    printf("%d ",*itr);
  }
  printf("\n");
}

int main() {

  list<int> coll;
  generate_n(back_inserter(coll),9,IntSequence(1));
  print_elements(coll);

  generate(++coll.begin(),--coll.end(),IntSequence(42));
  print_elements(coll);

  return 0;
}
