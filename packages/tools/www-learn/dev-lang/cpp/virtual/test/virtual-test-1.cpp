// Dominic Connor: C++ with confidence

#include <stdlib.h>
#include <iostream>

using namespace std;

    class Bond {
    public:
      virtual void WhatAmI (void) { cout << "Bond\n"; }
    };
    class Warrant : public Bond {
    public:
      void WhatAmI (void) { cout << "Warrant\n"; }
    };

    void Leppard(void) {
      Warrant * w = new Warrant;
      Bond * b = w;
      w->WhatAmI();
      b->WhatAmI();
    }

int main() {
  Leppard();
}
