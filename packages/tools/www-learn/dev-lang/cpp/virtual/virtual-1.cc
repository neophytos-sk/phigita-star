#include <iostream>

using namespace std;

class Bond {
public:
  virtual void WhatAmI (void) { cout << "Bond\n"; }
  virtual void test(void) { cout << "Hello\n" ; }
  virtual void hello(void) = 0;
};

class Warrant : public Bond {
public:
  void WhatAmI (void) { cout << "Warrant\n"; }
  void test(void) { cout << "Warrant\n"; }
  void hello(void) { cout << "hey\n";} 
};

void Leppard(void) {
  Warrant * w = new Warrant;
  Bond * b = w;
  w->WhatAmI();
  b->WhatAmI();
  b->test();
  w->test();
  //Bond b2;
  //b2.test();
  Warrant w2;
  w2.test();
  w2.hello();
  w->hello();
  b->hello();
  //b2.hello();
}

int main() {
  Leppard();
  return 0;
}
