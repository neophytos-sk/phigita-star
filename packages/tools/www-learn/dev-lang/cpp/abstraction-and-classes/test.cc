#include <iostream>

using std::cout;

class A {
public:
  virtual void test() { cout << "test\n"; }
  virtual void test1() { cout << "test1: hello world\n"; }
  void test2() { cout << "test2: hello world\n"; }
};

class B : public A {
public:
  void test() { cout << "test from B\n"; }
  void test1() { A::test1(); cout << "test1: hello from class b\n"; }
  void test2() { A::test2(); cout << "test2: hello from class b\n"; }
};

int main() {
  A* obj = new B;
  obj->test1();
  obj->test2();
  B b;
  b.test();
  b.test1();
  b.test2();
  return 0;
}
