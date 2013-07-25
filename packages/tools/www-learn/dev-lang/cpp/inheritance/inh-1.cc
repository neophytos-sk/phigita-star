#include <iostream>

using std::cout;
using std::endl;

class X {
public:
  void set_a(int value) { a_ = value; }
  virtual void set_b(int value) { b_ = value; }
  void print() { cout << "a_=" << a_ << " b_=" << b_ << endl; }

protected:
  int a_;
  int b_;
};


class Y : public X {
public:
  virtual void set_b(int value) { b_ = 100 * value; }
};


int main() {
  X x1;
  Y y1;
  X *x = new Y;

  x1.set_a(5);
  x1.set_b(10);
  x1.print();

  y1.set_a(5);
  y1.set_b(10);
  y1.print();

  x->set_a(5);
  x->set_b(10);
  x->print();
  return 0;
}
