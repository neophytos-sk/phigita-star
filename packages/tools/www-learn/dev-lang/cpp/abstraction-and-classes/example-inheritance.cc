#include <iostream>
#include "example-inheritance.h"

using std::cout;
using std::endl;

X::X(int myValue) { 
  myValue_ = myValue; 
}

void X::display() { 
  cout << "X::display myValue_=" << myValue_ << endl; 
}

void X::display2() { 
  cout << "X::display2 myValue_=" << myValue_ << endl; 
}

X::~X() {
  cout << "base class destructor" << endl; 
}


Y::Y(int myValue, int mySecondValue) : X(myValue) { mySecondValue_ = mySecondValue; }

void Y::display() { 
  X::display();
  cout << "Y::display mySecondValue_=" << mySecondValue_ << endl; 
}

void Y::display2() { 
  X::display2();
  cout << "Y::display2 mySecondValue_=" << mySecondValue_ << endl; 
}

Y::~Y() { 
  cout << "derived class destructor " << mySecondValue_ << endl; 
}




int main() {
  X *x = new Y(3,5);
  x->display();
  x->display2();
  delete x; // seems to be required

  Y y(6,7);
  y.display();
  y.display2();

  return 0;
}
