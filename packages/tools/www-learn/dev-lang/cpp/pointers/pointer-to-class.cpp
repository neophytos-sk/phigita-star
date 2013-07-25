#include <iostream>
using namespace std;

class MyClass
{
public:
  int m_Number;
  int m_Character;
  MyClass() { cout << "constructor" << endl; }
  ~MyClass() { cout << "destructor" << endl; }
  void show() {
    cout << "m_Number=" << m_Number << " m_Character=" << m_Character << endl;
  }
};

main()
{
  MyClass *pPointer;
  pPointer = new MyClass;

  pPointer->m_Number = 19;
  pPointer->m_Character = 's';

  pPointer->show();

  delete pPointer;
}
