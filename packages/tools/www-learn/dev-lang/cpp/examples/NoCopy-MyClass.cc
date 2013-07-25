#include <iostream>
#include <memory>

using namespace std;

class NoCopy
{
protected:
  NoCopy() {};
  ~NoCopy() {};  // protected non-virtual destructor
private:
  // copy ops are private to prevent copying
  NoCopy(const NoCopy&);             // no implementation
  NoCopy& operator=(const NoCopy&);  // no implementation
};
  
class MyClass : private NoCopy 
{
public:
  MyClass() { cout << "hello world" << endl; }
  ~MyClass() { cout << "and goodbye!" << endl; }
  void test() { cout << "enough said" << endl; }
};

void sayHi() {
  auto_ptr<MyClass> ptr(new MyClass);
  // MyClass *ptr = new MyClass();
  ptr->test();
}


int main()
{
  sayHi();
  return 0;
}

