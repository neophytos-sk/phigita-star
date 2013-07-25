// Dominic Connor: C++ with confidence
#include <stdlib.h>
#include <iostream>

using namespace std;

class Bond {
public:
  double virtual Price(double rate) { return rate *25;}
};
class Warrant : public Bond {
public:
  double Price(int WarID) { return 1; }
};

void Leppard(void) {
  Warrant * w = new Warrant;
  Bond * b = dynamic_cast <Bond *> (w);
  w = reinterpret_cast<Warrant *> (b);
  b = static_cast<Bond *> (w);
  double rate = 0.15;
  cout << "Price=" << w->Price(rate) << '\n';
}

int main() {
  Leppard();
}
