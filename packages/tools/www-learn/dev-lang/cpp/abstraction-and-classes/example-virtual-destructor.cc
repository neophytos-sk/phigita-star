#include <iostream>

using namespace std;

class a {
  public:
  a(){cout << "base constructor" << endl;}
  // ~a(){cout << "base destructor" << endl;}
  virtual ~a(){cout << "base destructor" << endl;} // virtual destructor
};

class b : public a {
  public:
  b(){cout << "derived constructor" << endl; }
  ~b(){cout << "derived destructor" << endl; }
};

int main(){
 a* obj = new b;
 delete obj;
 return 0;
}
