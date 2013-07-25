#include <iostream>

using namespace std;

class MyClass 
{
public:
  int getStaticValue() const {
    return myStaticValue;
  }
  void setStaticValue(int myValue)
  {
    myStaticValue = myValue;
  }
private:
  static int myStaticValue;
};

int MyClass::myStaticValue = 0;

int main()
{
  MyClass a;
  MyClass b;

  cout << b.getStaticValue() << endl;
  a.setStaticValue(137);
  cout << b.getStaticValue() << endl;

  return 0;
}
