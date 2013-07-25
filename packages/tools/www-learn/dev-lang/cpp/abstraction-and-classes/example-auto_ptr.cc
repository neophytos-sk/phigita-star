#include <iostream>
#include <memory>

using namespace std;

class X {
public:
  X(int myValue) { myValue_ = myValue; }
  virtual void display() { cout << "X::display myValue_=" << myValue_ << endl; }
  void display2() { cout << "X::display2 myValue_=" << myValue_ << endl; }
  virtual ~X() {cout << "base class destructor" << endl; }
private:
  int myValue_;
};

class Y : public X {
public:
  Y(int myValue, int mySecondValue) : X(myValue) { mySecondValue_ = mySecondValue; }
  void display() { 
    X::display();
    cout << "Y::display mySecondValue_=" << mySecondValue_ << endl; 
  }
  void display2() { 
    X::display2();
    cout << "Y::display2 mySecondValue_=" << mySecondValue_ << endl; 
  }
  ~Y() { cout << "derived class destructor " << mySecondValue_ << endl; }
private:
  int mySecondValue_;
};



int main() {
  //X *x = new Y(3,5);
  auto_ptr<X> x = (new Y(3,5));
  x->display();
  x->display2();
  //delete x; // seems to be required

  return 0;
}
